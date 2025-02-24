# AVFoundation HLS Monitor

A command-line tool for monitoring HLS (HTTP Live Streaming) streams using AVFoundation.

## Features

- Real-time monitoring of HLS streams
- Display of key streaming metrics:
  - Playback status and duration
  - Video quality
  - Bitrate (indicated and observed)
  - Buffer status
  - Stall count
  - Dropped frames
  - Network transfer statistics

## Requirements

- macOS 12.0 or later
- Swift 5.5 or later

## Installation

```bash
# Clone the repository
git clone https://github.com/Crisafulli-2/avfoundation-hls-monitor.git
cd avfoundation-hls-monitor

# Build the project
swift build -c release
```

## Usage

```bash
swift run hlsmonitor <stream_url>
```

### Example
```bash
swift run hlsmonitor "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
```

## Metrics Reference

| Metric | Description |
|--------|-------------|
| Time | Current timestamp |
| Position | Current playback position |
| Stream Duration | Total stream duration |  # Changed from "Duration"
| Quality | Video resolution |
| Indicated | Indicated bitrate |
| Observed | Observed bitrate |
| Buffer | Buffer duration |
| Stalls | Number of playback stalls |
| Dropped | Number of dropped frames |
| Bytes | Total bytes transferred |
| Transfer | Transfer rate |
| Empty | Buffer empty status |
| KeepUp | Playback keep-up status |

## Development

### Built With
- [AVFoundation](https://developer.apple.com/documentation/avfoundation) - Apple's media framework
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Command-line interface
- [Rainbow](https://github.com/onevcat/Rainbow) - Terminal output styling

### Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - See LICENSE file for details