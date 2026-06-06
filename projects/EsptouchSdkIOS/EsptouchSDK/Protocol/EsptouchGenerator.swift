import Foundation

/// ESP-Touch generator for creating broadcast data
class EsptouchGenerator {
    
    private let mDatumCode: DatumCode
    private let apSsid: [UInt8]
    private let apBssid: [UInt8]
    private let apPassword: [UInt8]
    
    /// Initialize with network credentials
    /// - Parameters:
    ///   - apSsid: SSID bytes
    ///   - apBssid: BSSID bytes
    ///   - apPassword: Password bytes
    init(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8]) {
        self.apSsid = apSsid
        self.apBssid = apBssid
        self.apPassword = apPassword
        self.mDatumCode = DatumCode()
    }
    
    /// Generate broadcast data packets
    /// - Returns: Array of data packets to broadcast
    func generateBroadcastData() -> [[UInt8]] {
        // Generate with XOR switch = false (true will be generated separately)
        return mDatumCode.getBytes(
            apSsid: apSsid,
            apBssid: apBssid,
            apPassword: apPassword,
            xorswitch: false
        )
    }
    
    /// Generate broadcast data packets with XOR switch
    /// - Parameters:
    ///   - xor: Whether to apply XOR switch
    /// - Returns: Array of data packets
    func generateBroadcastData(xor: Bool) -> [[UInt8]] {
        return mDatumCode.getBytes(
            apSsid: apSsid,
            apBssid: apBssid,
            apPassword: apPassword,
            xorswitch: xor
        )
    }
}
