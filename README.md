# AVFoundation HLS Monitor

A command-line tool for monitoring HLS (HTTP Live Streaming) streams using AVFoundation.

## Features

- Real-time monitoring of HLS streams
- Display of key metrics including bitrate, buffer status, and dropped frames
- Clean shutdown with SIGINT handling (Ctrl+C)
- Colored output for better readability

## Requirements

- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later (for development)

## Installation

```bash
git clone https://github.com/yourusername/avfoundation-hls-monitor.git
cd avfoundation-hls-monitor
swift build -c release
```

## Usage

```bash
swift run hlsmonitor <stream_url>
```

Example:
```bash
swift run hlsmonitor https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8
```

## Metrics Displayed

- Playback buffer status
- Current bitrate
- Dropped frames count
- Loaded time ranges
- Stream timestamp

## Development

To set up the development environment:

```bash
# Clone the repository
git clone https://github.com/yourusername/avfoundation-hls-monitor.git

# Navigate to the project directory
cd avfoundation-hls-monitor

# Build the project
swift build

# Run tests
swift test
```

## License

MIT License

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request