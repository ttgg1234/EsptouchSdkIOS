import Foundation

/// Touch data wrapper
public class TouchData {
    
    private let data: [UInt8]
    
    /// Initialize with byte array
    /// - Parameter data: Byte array
    public init(_ data: [UInt8]) {
        self.data = data
    }
    
    /// Initialize with string (converted to UTF-8 bytes)
    /// - Parameter string: String data
    public convenience init(_ string: String) {
        self.init(Array(string.utf8))
    }
    
    /// Get data bytes
    /// - Returns: Byte array
    public func getData() -> [UInt8] {
        return data
    }
    
    /// Get data length
    /// - Returns: Length of data
    public func getLength() -> Int {
        return data.count
    }
}
