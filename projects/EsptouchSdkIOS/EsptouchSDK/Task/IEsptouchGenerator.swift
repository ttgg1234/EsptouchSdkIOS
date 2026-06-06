import Foundation

/// Protocol for ESP-Touch generator
public protocol IEsptouchGenerator {
    func generateBroadcastData() -> [[UInt8]]
}
