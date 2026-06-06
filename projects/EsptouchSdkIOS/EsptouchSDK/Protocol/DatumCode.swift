import Foundation

/// Datum code generator for ESP-Touch protocol
/// Combines guide code and data code into complete broadcast packets
class DatumCode {
    
    private let mGuideCode: GuideCode
    private let mDataCode: DataCode
    
    init() {
        self.mGuideCode = GuideCode()
        self.mDataCode = DataCode(totalLen: EsptouchConstant.TOTAL_DATA_LEN)
    }
    
    /// Generate complete datum code
    /// - Parameters:
    ///   - apSsid: SSID data
    ///   - apBssid: BSSID data
    ///   - apPassword: Password data
    ///   - xorswitch: Whether to use XOR switch
    /// - Returns: Complete datum code bytes
    func getBytes(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8], xorswitch: Bool) -> [[UInt8]] {
        var datumCode = [[UInt8]]()
        
        // Add guide code
        datumCode.append(contentsOf: mGuideCode.getBytes())
        
        // Add data code
        datumCode.append(contentsOf: mDataCode.getBytes(
            apSsid: apSsid,
            apBssid: apBssid,
            apPassword: apPassword,
            xorswitch: xorswitch
        ))
        
        return datumCode
    }
}
