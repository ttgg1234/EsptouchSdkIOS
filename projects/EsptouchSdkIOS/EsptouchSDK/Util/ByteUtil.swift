import Foundation

/// Byte utility functions for ESP-Touch protocol
public class ByteUtil {
    
    /// Get bytes from hex string
    /// - Parameter hexString: Hex string (e.g., "01020304")
    /// - Returns: Byte array
    public static func getBytesByHexString(_ hexString: String) -> [UInt8] {
        var data = [UInt8]()
        var tempString = hexString
        while tempString.count > 0 {
            let index = tempString.index(tempString.startIndex, offsetBy: 2)
            let byteString = String(tempString[..<index])
            tempString = String(tempString[index...])
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
        }
        return data
    }
    
    /// Convert string to bytes (UTF-8)
    /// - Parameter string: Input string
    /// - Returns: Byte array
    public static func getBytesByString(_ string: String) -> [UInt8] {
        return Array(string.utf8)
    }
    
    /// Split data into chunks
    /// - Parameters:
    ///   - data: Source data
    ///   - len: Chunk length
    /// - Returns: Array of data chunks
    public static func splitData(_ data: [UInt8], len: Int) -> [[UInt8]] {
        var result = [[UInt8]]()
        var index = 0
        while index < data.count {
            let endIndex = min(index + len, data.count)
            result.append(Array(data[index..<endIndex]))
            index = endIndex
        }
        return result
    }
    
    /// Generate specific length data from string
    /// - Parameters:
    ///   - string: Input string
    ///   - len: Target length
    /// - Returns: Padded byte array
    public static func generateSpecificData(_ string: String, len: Int) -> [UInt8] {
        var data = getBytesByString(string)
        while data.count < len {
            data.append(0)
        }
        return Array(data.prefix(len))
    }
    
    /// Combine two byte arrays
    /// - Parameters:
    ///   - src1: First byte array
    ///   - src2: Second byte array
    /// - Returns: Combined byte array
    public static func combine(_ src1: [UInt8], _ src2: [UInt8]) -> [UInt8] {
        return src1 + src2
    }
    
    /// Convert BSSID string to bytes
    /// - Parameter bssid: BSSID string (e.g., "00:11:22:33:44:55")
    /// - Returns: Byte array
    public static func parseBssid2bytes(_ bssid: String) -> [UInt8] {
        let parts = bssid.split(separator: ":").map { String($0) }
        return parts.compactMap { UInt8($0, radix: 16) }
    }
    
    /// Check if two byte arrays are equal
    /// - Parameters:
    ///   - b1: First byte array
    ///   - b2: Second byte array
    /// - Returns: Whether they are equal
    public static func equals(_ b1: [UInt8], _ b2: [UInt8]) -> Bool {
        if b1.count != b2.count {
            return false
        }
        for i in 0..<b1.count {
            if b1[i] != b2[i] {
                return false
            }
        }
        return true
    }
    
    /// Convert byte to binary string
    /// - Parameter b: Byte value
    /// - Returns: 8-bit binary string
    public static func toBinaryString(_ b: UInt8) -> String {
        return String(b, radix: 2).leftPadding(toLength: 8, withPad: "0")
    }
    
    /// Convert byte array to hex string
    /// - Parameter bytes: Byte array
    /// - Returns: Hex string
    public static func bytesToHexString(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02X", $0) }.joined()
    }
}

extension String {
    /// Left pad string to specified length
    /// - Parameters:
    ///   - length: Target length
    ///   - pad: Padding character
    /// - Returns: Padded string
    func leftPadding(toLength length: Int, withPad pad: String) -> String {
        if self.count >= length {
            return self
        }
        return String(repeating: pad, count: length - self.count) + self
    }
}
