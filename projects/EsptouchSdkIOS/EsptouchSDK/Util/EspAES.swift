import Foundation
import CommonCrypto

/// ESP AES encryption utility
public class EspAES {
    
    private let key: [UInt8]
    
    /// Initialize with AES key
    /// - Parameter key: 16-byte AES key
    public init(key: [UInt8]) {
        self.key = key
    }
    
    /// Encrypt data using AES
    /// - Parameter plain: Plain text data
    /// - Returns: Encrypted data (IV prepended)
    public func encrypt(_ plain: [UInt8]) -> [UInt8] {
        guard !plain.isEmpty else { return plain }
        
        // Generate random IV
        var iv = [UInt8](repeating: 0, count: kCCBlockSizeAES128)
        let status = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)
        guard status == errSecSuccess else { return plain }
        
        // Pad data to block size
        var paddedData = plain
        let paddingLength = kCCBlockSizeAES128 - (plain.count % kCCBlockSizeAES128)
        for _ in 0..<paddingLength {
            paddedData.append(UInt8(paddingLength))
        }
        
        var encryptedData = [UInt8](repeating: 0, count: paddedData.count)
        var bytesEncrypted = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            key, key.count,
            iv,
            paddedData, paddedData.count,
            &encryptedData, paddedData.count,
            &bytesEncrypted
        )
        
        guard cryptStatus == kCCSuccess else { return plain }
        
        // Prepend IV to encrypted data
        return iv + Array(encryptedData.prefix(bytesEncrypted))
    }
    
    /// Decrypt data using AES
    /// - Parameter encrypted: Encrypted data (IV prepended)
    /// - Returns: Decrypted data
    public func decrypt(_ encrypted: [UInt8]) -> [UInt8] {
        guard encrypted.count > kCCBlockSizeAES128 else { return encrypted }
        
        // Extract IV
        let iv = Array(encrypted.prefix(kCCBlockSizeAES128))
        let cipherData = Array(encrypted.dropFirst(kCCBlockSizeAES128))
        
        var decryptedData = [UInt8](repeating: 0, count: cipherData.count)
        var bytesDecrypted = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            key, key.count,
            iv,
            cipherData, cipherData.count,
            &decryptedData, cipherData.count,
            &bytesDecrypted
        )
        
        guard cryptStatus == kCCSuccess else { return encrypted }
        
        // Remove padding
        if bytesDecrypted > 0 {
            let paddingLength = Int(decryptedData[bytesDecrypted - 1])
            if paddingLength <= kCCBlockSizeAES128 && paddingLength <= bytesDecrypted {
                return Array(decryptedData.prefix(bytesDecrypted - paddingLength))
            }
        }
        
        return Array(decryptedData.prefix(bytesDecrypted))
    }
}
