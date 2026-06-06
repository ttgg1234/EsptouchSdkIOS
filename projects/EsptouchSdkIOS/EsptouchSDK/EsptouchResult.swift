import Foundation

/// Protocol for ESP-Touch result
public protocol IEsptouchResult {
    /// Get BSSID of the device
    func getBssid() -> String?
    
    /// Get IP address of the device
    func getInetAddress() -> String?
    
    /// Check if the operation is successful
    func isSuc() -> Bool
    
    /// Check if cancelled
    func isCancelled() -> Bool
    
    /// Set cancelled state
    func setIsCancelled(_ cancelled: Bool)
}

/// ESP-Touch result implementation
public class EsptouchResult: IEsptouchResult {
    
    private let isSuc: Bool
    private let bssid: String?
    private let inetAddress: String?
    private var isCancelled: Bool = false
    
    /// Initialize with result data
    /// - Parameters:
    ///   - isSuc: Whether successful
    ///   - bssid: Device BSSID
    ///   - inetAddress: Device IP address
    public init(isSuc: Bool, bssid: String?, inetAddress: String?) {
        self.isSuc = isSuc
        self.bssid = bssid
        self.inetAddress = inetAddress
    }
    
    public func getBssid() -> String? {
        return bssid
    }
    
    public func getInetAddress() -> String? {
        return inetAddress
    }
    
    public func isSuc() -> Bool {
        return isSuc
    }
    
    public func isCancelled() -> Bool {
        return isCancelled
    }
    
    public func setIsCancelled(_ cancelled: Bool) {
        self.isCancelled = cancelled
    }
}
