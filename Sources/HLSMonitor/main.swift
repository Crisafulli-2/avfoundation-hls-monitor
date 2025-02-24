import AVFoundation
import Foundation
import ArgumentParser
import Rainbow

private var globalMonitor: HLSStreamMonitor?

@main
struct HLSMonitor: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "hlsmonitor",
        abstract: "Monitor HLS streams and display real-time metrics"
    )
    
    @Argument(help: "The URL of the HLS stream to monitor")
    var streamURL: String
    
    mutating func run() throws {
        guard let url = URL(string: streamURL) else {
            throw ValidationError("Invalid URL provided")
        }
        
        signal(SIGINT) { _ in
            print("\nGracefully shutting down...".yellow)
            globalMonitor?.stopMonitoring()
            Darwin.exit(0)
        }
        
        let monitor = HLSStreamMonitor()
        globalMonitor = monitor
        monitor.startMonitoring(url: url)
        
        RunLoop.main.run()
    }
}

final class HLSStreamMonitor {
    private let player: AVPlayer
    private var asset: AVAsset?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private let metricsQueue = DispatchQueue(label: "com.hlsmonitor.metrics", qos: .utility)
    private var isMonitoring = false
    
    init() {
        self.player = AVPlayer()
        player.isMuted = true
    }
    
    func startMonitoring(url: URL) {
        isMonitoring = true
        
        let assetKeys = ["playable", "tracks", "duration"]
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        asset = AVURLAsset(url: url, options: options)
        
        guard let asset = asset else { return }
        
        asset.loadValuesAsynchronously(forKeys: assetKeys) { [weak self] in
            DispatchQueue.main.async {
                self?.setupPlayerItem(with: asset)
            }
        }
    }
    
    private func setupPlayerItem(with asset: AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        setupObservers()
        player.play()
    }
    
    private func setupObservers() {
        guard let playerItem = playerItem else { return }
        
        statusObserver = playerItem.observe(\.status) { [weak self] item, _ in
            switch item.status {
            case .failed:
                print("Error: \(String(describing: item.error))".red)
                self?.stopMonitoring()
            case .readyToPlay:
                print("Stream ready to play".green)
            default:
                break
            }
        }
        
        let interval = CMTime(seconds: 2.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: metricsQueue) { [weak self] _ in
            self?.updatePlaybackMetrics()
        }
    }
    
    private func updatePlaybackMetrics() {
        guard let playerItem = playerItem, isMonitoring else { return }
        
        autoreleasepool {
            let metrics = collectMetrics(from: playerItem)
            displayMetrics(metrics)
        }
    }

    private func collectMetrics(from playerItem: AVPlayerItem) -> [String: Any] {
        var metrics: [String: Any] = [:]
        
        if let event = playerItem.accessLog()?.events.last {
            let dimensions = playerItem.presentationSize
            let currentTime = playerItem.currentTime()
            
            metrics = [
                "Time": Date().formatted(date: .omitted, time: .standard),
                "Position": String(format: "%.2fs", CMTimeGetSeconds(currentTime)),
                "Duration": String(format: "%.2fs", CMTimeGetSeconds(playerItem.duration)),
                "Quality": "\(Int(dimensions.width))x\(Int(dimensions.height))",
                "Indicated": String(format: "%.2f Mbps", event.indicatedBitrate / 1_000_000),
                "Observed": String(format: "%.2f Mbps", event.observedBitrate / 1_000_000),
                "Buffer": String(format: "%.1fs", playerItem.loadedTimeRanges.first?.timeRangeValue.duration.seconds ?? 0),
                "Stalls": event.numberOfStalls,
                "Dropped": event.numberOfDroppedVideoFrames,
                "Bytes": String(format: "%.2f MB", Double(event.numberOfBytesTransferred) / 1_000_000),
                "Transfer": String(format: "%.2f Mbps", event.transferDuration > 0 ? Double(event.numberOfBytesTransferred) * 8 / event.transferDuration / 1_000_000 : 0),
                "Empty": playerItem.isPlaybackBufferEmpty ? "Yes" : "No",
                "KeepUp": playerItem.isPlaybackLikelyToKeepUp ? "Yes" : "No"
            ]
        }
        
        return metrics
    }
    
    private func displayMetrics(_ metrics: [String: Any]) {
        DispatchQueue.main.async {
            print("\n▶️  HLS Metrics".cyan.bold)
            print("──────────────────")
            metrics.forEach { key, value in
                print("\(key.padded(to: 12)): \(value)".white)
            }
            print("──────────────────")
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        player.pause()
        
        statusObserver?.invalidate()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
        
        playerItem?.cancelPendingSeeks()
        playerItem = nil
        asset?.cancelLoading()
        asset = nil
    }
}

private extension String {
    func padded(to length: Int) -> String {
        padding(toLength: length, withPad: " ", startingAt: 0)
    }
}