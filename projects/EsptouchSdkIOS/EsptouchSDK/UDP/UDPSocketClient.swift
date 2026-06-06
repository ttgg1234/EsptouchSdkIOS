import Foundation
import Darwin

/// UDP Socket client for sending broadcast data
public class UDPSocketClient {
    
    private var socket: Int32 = -1
    private var isClosed: Bool = false
    private var isStop: Bool = false
    
    /// Initialize UDP socket
    public init() {
        socket = Darwin.socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if socket >= 0 {
            // Enable broadcast
            var broadcastEnable: Int32 = 1
            setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, socklen_t(MemoryLayout<Int32>.size))
            
            // Set timeout
            var timeout = timeval(tv_sec: 0, tv_usec: 100000)
            setsockopt(socket, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        }
    }
    
    deinit {
        close()
    }
    
    /// Interrupt the socket
    public func interrupt() {
        isStop = true
    }
    
    /// Close the socket
    public func close() {
        if !isClosed && socket >= 0 {
            Darwin.close(socket)
            isClosed = true
        }
    }
    
    /// Send data via UDP
    /// - Parameters:
    ///   - data: Data packets to send
    ///   - targetHost: Target host address
    ///   - targetPort: Target port
    ///   - interval: Interval between packets (milliseconds)
    public func sendData(_ data: [[UInt8]], targetHost: String, targetPort: Int, interval: Int) {
        guard socket >= 0 && !isStop else { return }
        
        var targetAddr = sockaddr_in()
        targetAddr.sin_family = sa_family_t(AF_INET)
        targetAddr.sin_port = in_port_t(targetPort).bigEndian
        targetAddr.sin_addr.s_addr = inet_addr(targetHost)
        
        let targetAddrPtr = withUnsafePointer(to: &targetAddr) { ptr in
            return UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
        }
        
        for packet in data {
            guard !isStop else { break }
            
            let sendResult = packet.withUnsafeBytes { ptr -> Int in
                return sendto(socket, ptr.baseAddress, packet.count, 0, targetAddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
            
            if sendResult < 0 {
                // Continue sending even if some packets fail
            }
            
            // Sleep interval between packets
            if interval > 0 {
                Thread.sleep(forTimeInterval: Double(interval) / 1000.0)
            }
        }
        
        if isStop {
            close()
        }
    }
    
    /// Send data synchronously
    /// - Parameters:
    ///   - data: Data to send
    ///   - targetHost: Target host
    ///   - targetPort: Target port
    public func send(_ data: [UInt8], targetHost: String, targetPort: Int) {
        guard socket >= 0 else { return }
        
        var targetAddr = sockaddr_in()
        targetAddr.sin_family = sa_family_t(AF_INET)
        targetAddr.sin_port = in_port_t(targetPort).bigEndian
        targetAddr.sin_addr.s_addr = inet_addr(targetHost)
        
        let targetAddrPtr = withUnsafePointer(to: &targetAddr) { ptr in
            return UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
        }
        
        _ = data.withUnsafeBytes { ptr -> Int in
            return sendto(socket, ptr.baseAddress, data.count, 0, targetAddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
}
