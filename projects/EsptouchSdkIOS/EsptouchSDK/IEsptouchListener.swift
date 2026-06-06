import Foundation

/// Protocol for ESP-Touch listener
public protocol IEsptouchListener: AnyObject {
    /// Called when a result is added
    /// - Parameter result: The new result
    func onEsptouchResultAdded(_ result: IEsptouchResult)
}
