import Foundation

/// Task parameter for ESP-Touch
public class EsptouchTaskParameter {
    
    /// The interval between each UDP broadcast (milliseconds)
    private var broadcastInterval: Int = EsptouchConstant.BROADCAST_INTERVAL_MILLIS
    
    /// The timeout for waiting UDP response (milliseconds)
    private var waitUdpTotalMillisecond: Int = EsptouchConstant.WAIT_UDP_TIME_MILLIS
    
    /// The port for listening UDP response
    private var portListening: Int = EsptouchConstant.PORT_LISTENING
    
    /// Whether to use broadcast
    private var broadcast: Bool = true
    
    /// The expected number of results
    private var expectTaskResultCount: Int = EsptouchConstant.EXPECT_TASK_RESULT_COUNT
    
    /// The threshold count for success broadcast
    private var thresholdSucBroadcastCount: Int = EsptouchConstant.THRESHOLD_SUC_BROADCAST_COUNT
    
    /// The timeout for waiting device connected (milliseconds)
    private var waitUdpDevConnectedMillisecond: Int = EsptouchConstant.WAIT_UDP_TIME_MILLIS_DEVCONN
    
    // MARK: - Getters and Setters
    
    public func getBroadcastInterval() -> Int {
        return broadcastInterval
    }
    
    public func setBroadcastInterval(_ interval: Int) {
        self.broadcastInterval = interval
    }
    
    public func getWaitUdpTotalMillisecond() -> Int {
        return waitUdpTotalMillisecond
    }
    
    public func setWaitUdpTotalMillisecond(_ timeout: Int) {
        self.waitUdpTotalMillisecond = timeout
    }
    
    public func getPortListening() -> Int {
        return portListening
    }
    
    public func setPortListening(_ port: Int) {
        self.portListening = port
    }
    
    public func isBroadcast() -> Bool {
        return broadcast
    }
    
    public func setBroadcast(_ broadcast: Bool) {
        self.broadcast = broadcast
    }
    
    public func getExpectTaskResultCount() -> Int {
        return expectTaskResultCount
    }
    
    public func setExpectTaskResultCount(_ count: Int) {
        self.expectTaskResultCount = count
    }
    
    public func getThresholdSucBroadcastCount() -> Int {
        return thresholdSucBroadcastCount
    }
    
    public func setThresholdSucBroadcastCount(_ count: Int) {
        self.thresholdSucBroadcastCount = count
    }
    
    public func getWaitUdpDevConnectedMillisecond() -> Int {
        return waitUdpDevConnectedMillisecond
    }
    
    public func setWaitUdpDevConnectedMillisecond(_ timeout: Int) {
        self.waitUdpDevConnectedMillisecond = timeout
    }
}
