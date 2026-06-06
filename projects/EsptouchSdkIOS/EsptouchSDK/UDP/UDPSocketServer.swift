import Foundation
import Darwin

/// UDP Socket server for receiving response data
public class UDPSocketServer {
    
    private var socket: Int32 = -1
    private var isClosed: Bool = false
    private let port: Int
    private let timeout: Int
    private var buffer: [UInt8] = [UInt8](repeating: 0, count: 1024)
    
    /// Initialize UDP socket server
    /// - Parameters:
    ///   - port: Port to listen on
    ///   - timeout: Receive timeout (milliseconds)
    public init(port: Int, timeout: Int) {
        self.port = port
        self.timeout = timeout
        
        socket = Darwin.socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if socket >= 0 {
            // Allow address reuse
            var reuseAddr: Int32 = 1
            setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, socklen_t(MemoryLayout<Int32>.size))
            
            // Bind to port
            var localAddr = sockaddr_in()
            localAddr.sin_family = sa_family_t(AF_INET)
            localAddr.sin_port = in_port_t(port).bigEndian
            localAddr.sin_addr.s_addr = INADDR_ANY
            
            let bindResult = withUnsafePointer(to: &localAddr) { ptr in
                return UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
            }
            
            _ = bind(socket, bindResult, socklen_t(MemoryLayout<sockaddr_in>.size))
            
            // Set receive timeout
            var tv = timeval(tv_sec: timeout / 1000, tv_usec: Int32((timeout % 1000) * 1000))
            setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
        }
    }
    
    deinit {
        close()
    }
    
    /// Interrupt receiving
    public func interrupt() {
        // Set timeout to 0 to unblock receive
        var tv = timeval(tv_sec: 0, tv_usec: 0)
        setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
    }
    
    /// Close the socket
    public func close() {
        if !isClosed && socket >= 0 {
            Darwin.close(socket)
            isClosed = true
        }
    }
    
    /// Set socket receive timeout
    /// - Parameter timeout: Timeout in milliseconds
    public func setSoTimeout(_ timeout: Int) {
        var tv = timeval(tv_sec: timeout / 1000, tv_usec: Int32((timeout % 1000) * 1000))
        setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
    }
    
    /// Receive data of specified length
    /// - Parameter expectLen: Expected data length
    /// - Returns: Received data or nil
    public func receiveSpecLenBytes(_ expectLen: Int) -> [UInt8]? {
        guard socket >= 0 else { return nil }
        
        var senderAddr = sockaddr_in()
        var senderAddrLen = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        let senderAddrPtr = withUnsafeMutablePointer(to: &senderAddr) { ptr in
            return UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
        }
        
        let receivedLen = buffer.withUnsafeMutableBytes { ptr -> Int in
            return recvfrom(socket, ptr.baseAddress, buffer.count, 0, senderAddrPtr, &senderAddrLen)
        }
        
        if receivedLen > 0 {
            return Array(buffer.prefix(min(receivedLen, expectLen)))
        }
        
        return nil
    }
}
