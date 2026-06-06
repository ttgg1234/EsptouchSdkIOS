import Foundation

/// Data code generator for ESP-Touch protocol
/// The data code contains the SSID, BSSID, password and other information
class DataCode {
    
    private let mTotalLen: Int
    
    init(totalLen: Int) {
        self.mTotalLen = totalLen
    }
    
    /// Generate data codes from data
    /// - Parameters:
    ///   - apSsid: SSID data
    ///   - apBssid: BSSID data
    ///   - apPassword: Password data
    ///   - xorswitch: Whether to use XOR switch
    /// - Returns: Array of data code bytes
    func getBytes(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8], xorswitch: Bool) -> [[UInt8]] {
        var codes = [[UInt8]]()
        
        // SSID length and data
        let ssidLen = UInt8(min(apSsid.count, 32))
        codes.append([ssidLen])
        
        // BSSID data
        codes.append(apBssid)
        
        // Password length and data
        let pwdLen = UInt8(min(apPassword.count, 64))
        codes.append([pwdLen])
        
        // Concatenate all data
        var allData: [UInt8] = [ssidLen] + apBssid + [pwdLen] + apPassword
        while allData.count < mTotalLen {
            allData.append(0)
        }
        
        // Split into chunks of 6 bytes (since we need 9 bits per byte in protocol)
        let chunks = ByteUtil.splitData(Array(allData.prefix(mTotalLen)), len: 6)
        
        var dataCodes = [[UInt8]]()
        for chunk in chunks {
            var paddedChunk = chunk
            while paddedChunk.count < 6 {
                paddedChunk.append(0)
            }
            
            // Convert to 9-bit format
            let dataCode = convertTo9BitFormat(paddedChunk, xorswitch: xorswitch)
            dataCodes.append(dataCode)
        }
        
        return dataCodes + codes
    }
    
    private func convertTo9BitFormat(_ data: [UInt8], xorswitch: Bool) -> [UInt8] {
        // In ESP-Touch protocol, each 6 bytes become 9 bytes
        // The 9th bit is used for control information
        var result = [UInt8]()
        
        for i in 0..<min(data.count, 6) {
            var byte = data[i]
            if xorswitch {
                byte ^= 0x20
            }
            
            // First 8 bits
            result.append(byte)
            // 9th bit (control bit)
            let controlBit: UInt8 = (i == 5) ? 0 : 1
            result.append(controlBit)
        }
        
        return result
    }
}
