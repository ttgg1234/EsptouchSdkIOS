# ESP-Touch WiFi Provisioning iOS SDK

This is the iOS version of the ESP-Touch WiFi provisioning project. It allows iOS devices to configure ESP8266/ESP32 devices to connect to a WiFi network.

## Project Structure

```
EsptouchSdkIOS/
├── EsptouchSDK/              # Core SDK framework
│   ├── Protocol/             # ESP-Touch protocol implementation
│   ├── Task/                 # Task management
│   ├── UDP/                  # UDP socket client/server
│   ├── Util/                 # Utility classes
│   ├── EsptouchTask.swift    # Main task class
│   └── Esptouch.swift        # Public API
├── EsptouchDemo/             # Demo application
│   ├── ContentView.swift     # Main UI (SwiftUI)
│   └── Assets.xcassets/       # App assets
├── project.yml               # XcodeGen configuration
└── README.md                 # This file
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

## Installation

### 1. Install XcodeGen

```bash
# Using Homebrew
brew install xcodegen

# Or using Mint
mint install yonaskolb/xcodegen
```

### 2. Generate Xcode Project

Navigate to the project directory and run:

```bash
cd EsptouchSdkIOS
xcodegen generate
```

### 3. Open and Build

```bash
open EsptouchSdkIOS.xcodeproj
```

Then select your target device/simulator and build (⌘+B).

## Features

- **WiFi Provisioning**: Configure ESP8266/ESP32 devices to connect to WiFi
- **SwiftUI Interface**: Modern, clean user interface
- **Protocol Support**: Full ESP-Touch v2 protocol implementation
- **AES Encryption**: Optional AES encryption for secure provisioning

## Usage

### Basic Usage

```swift
import EsptouchSDK

// Get current WiFi info (requires entitlements)
let ssid = getCurrentWiFiSSID()
let bssid = getCurrentWiFiBSSID()

// Start provisioning
Esptouch.startProvision(
    ssid: ssid,
    bssid: bssid,
    password: "yourWiFiPassword",
    timeout: 60000
) { result in
    switch result {
    case .success(let results):
        if let device = results.first, device.isSuc() {
            print("Device configured: \(device.getBssid() ?? "")")
        }
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Using EsptouchTask Directly

```swift
let task = EsptouchTask(
    apSsid: "WiFiName",
    apBssid: "AA:BB:CC:DD:EE:FF",
    apPassword: "password123"
)

task.setEsptouchListener(self)
let results = task.executeForResults(1)
```

## Required Capabilities

To use this SDK, you need to enable the following capabilities in your Xcode project:

1. **Access WiFi Information** (com.apple.developer.networking.wifi-info)
2. **Local Network Access**
3. **Bonjour Services** (_esptouch._udp)

### Entitlements

Add these to your app's entitlements file:

```xml
<key>com.apple.developer.networking.wifi-info</key>
<true/>
<key>com.apple.developer.networking.multicast</key>
<true/>
```

### Info.plist Additions

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to the local network to configure WiFi devices.</string>
<key>NSBonjourServices</key>
<array>
    <string>_esptouch._udp</string>
</array>
```

## iOS Limitations

**Important**: On iOS, you cannot programmatically obtain the current WiFi SSID/BSSID without user location permission. The app needs:

1. Location permission (When In Use) - Required to access WiFi info
2. Local Network permission - Required for UDP broadcast

Users must be connected to a 2.4GHz WiFi network for ESP device provisioning.

## Protocol Implementation

The SDK implements the ESP-Touch protocol:
- **Guide Code**: Synchronization sequence sent before data
- **Data Code**: Contains SSID, BSSID, and password
- **Broadcast**: UDP packets sent to 255.255.255.255:7001
- **Response**: UDP response received on port 18266

## Migration from Android

Key differences from Android version:

| Android | iOS |
|---------|-----|
| WifiManager | CNCopyCurrentNetworkInfo |
| AsyncTask | DispatchQueue/Thread |
| Handler | DispatchQueue.main.async |
| EsptouchTask | EsptouchTask (same API) |
| IEsptouchListener | IEsptouchListener (same API) |

## License

Same as the original Android project.

## References

- [ESP-Touch Protocol Specification](https://www.espressif.com/sites/default/files/documentation/esp-touch_user_guide_en.pdf)
- [Espressif IoT Development Framework](https://github.com/EspressifApp/EsptouchForAndroid)
