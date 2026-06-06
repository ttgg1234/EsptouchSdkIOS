import Foundation

/// CRC8 calculator for ESP-Touch protocol
public class CRC8 {
    
    private static let POLYNOMIAL: UInt8 = 0x07
    
    /// Calculate CRC8 for data
    /// - Parameter data: Input byte array
    /// - Returns: CRC8 value
    public static func caculate(_ data: [UInt8]) -> UInt8 {
        var crc: UInt8 = 0
        
        for byte in data {
            crc ^= byte
            for _ in 0..<8 {
                if (crc & 0x80) != 0 {
                    crc = (crc << 1) ^ POLYNOMIAL
                } else {
                    crc <<= 1
                }
            }
        }
        
        return crc
    }
}
