import Foundation
import SystemConfiguration

/// ESP network utility functions
public class EspNetUtil {
    
    /// Get local IP address
    /// - Returns: Local IP address string or nil
    public static func getLocalIPv4() -> String? {
        var address: String?
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                if name == "en0" {  // WiFi interface
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0),
                        NI_NUMERICHOST
                    )
                    address = String(cString: hostname)
                    break
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return address
    }
    
    /// Get broadcast address for WiFi
    /// - Returns: Broadcast address string
    public static func getBroadcastAddress() -> String {
        return "255.255.255.255"
    }
    
    /// Parse BSSID string to byte array
    /// - Parameter bssid: BSSID string (e.g., "00:11:22:33:44:55")
    /// - Returns: Byte array
    public static func parseBssid2bytes(_ bssid: String) -> [UInt8] {
        return ByteUtil.parseBssid2bytes(bssid)
    }
}
