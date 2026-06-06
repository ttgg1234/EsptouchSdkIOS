import Foundation

/// Guide code generator for ESP-Touch protocol
/// The guide code is used to help devices sync with the sender
class GuideCode {
    
    /// Get guide code data
    /// - Returns: Array of guide code bytes
    func getBytes() -> [[UInt8]] {
        return [
            generateOneGuideCode(0),
            generateOneGuideCode(1),
            generateOneGuideCode(0),
            generateOneGuideCode(1)
        ]
    }
    
    private func generateOneGuideCode(_ b: UInt8) -> [UInt8] {
        var guideCode = [UInt8]()
        let count = b == 0 ? 1 : 2
        
        for _ in 0..<count {
            guideCode.append(0xFF)
        }
        
        return guideCode
    }
}
