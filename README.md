# SystemSound

SystemSound is a Swift package that provides a simple and efficient way to interact with macOS system audio settings. It allows you to monitor and control the system's default audio device, volume, and mute status.

## Features

- Get and set mute status
- Get and set system volume
- Increase/Decrease volume by a specified amount
- Observe changes in default audio device, mute and volume status

## Requirements

- macOS 10.13+
- Swift 5.0+

## Installation

### CocoaPods

SystemSound is available through CocoaPods. To install it, simply add the following line to your Podfile:

```ruby
pod 'SystemSound', :git => 'https://github.com/sunnyyoung/SystemSound.git', :tag => '1.0.0'
```

### Swift Package Manager

You can add SystemSound to your project using Swift Package Manager. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/sunnyyoung/SystemSound.git", from: "1.0.0")
]
```

## Usage

### Initializing

```swift

import SystemSound

SystemSound.global.load()
```

### Getting and Setting Volume/Mute Status

```swift
// Get current volume and mute status
let (muted, volume) = SystemSound.global.value

// Set volume and mute status
SystemSound.global.value = (muted: false, volume: 0.5)
```

### Adjusting Volume

```swift
// Increase volume by 10%
SystemSound.global.increaseVolume()

// Decrease volume by 10%
SystemSound.global.decreaseVolume()
```

### Observing Changes

```swift
NotificationCenter.default.addObserver(forName: .SoundServiceDefaultDeviceDidChange, object: nil, queue: .main) { _ in
    print("default audio device changed")
}

NotificationCenter.default.addObserver(forName: .SoundServiceMutedDidChange, object: nil, queue: .main) { _ in
    print("mute status changed")
}

NotificationCenter.default.addObserver(forName: .SoundServiceVolumeDidChange, object: nil, queue: .main) { _ in
    print("volume changed")
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

The [MIT](LICENSE) License.
