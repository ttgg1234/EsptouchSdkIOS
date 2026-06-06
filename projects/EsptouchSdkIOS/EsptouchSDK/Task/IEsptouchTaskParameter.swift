import Foundation

/// Protocol for ESP-Touch task parameter
public protocol IEsptouchTaskParameter {
    func getBroadcastInterval() -> Int
    func setBroadcastInterval(_ interval: Int)
    func getWaitUdpTotalMillisecond() -> Int
    func setWaitUdpTotalMillisecond(_ timeout: Int)
    func getPortListening() -> Int
    func setPortListening(_ port: Int)
    func isBroadcast() -> Bool
    func setBroadcast(_ broadcast: Bool)
    func getExpectTaskResultCount() -> Int
    func setExpectTaskResultCount(_ count: Int)
    func getThresholdSucBroadcastCount() -> Int
    func setThresholdSucBroadcastCount(_ count: Int)
}
