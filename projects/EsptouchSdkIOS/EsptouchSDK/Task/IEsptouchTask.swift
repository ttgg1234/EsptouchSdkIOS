import Foundation

/// Protocol for ESP-Touch task
public protocol IEsptouchTask {
    
    /// Interrupt the task
    func interrupt()
    
    /// Execute and return single result
    /// - Returns: ESP-Touch result
    func executeForResult() -> IEsptouchResult?
    
    /// Check if task is cancelled
    /// - Returns: Whether cancelled
    func isCancelled() -> Bool
    
    /// Execute and return multiple results
    /// - Parameter expectTaskResultCount: Expected result count
    /// - Returns: List of results
    func executeForResults(_ expectTaskResultCount: Int) -> [IEsptouchResult]
    
    /// Set listener for results
    /// - Parameter listener: Result listener
    func setEsptouchListener(_ listener: IEsptouchListener)
    
    /// Set whether to use broadcast
    /// - Parameter broadcast: Whether to broadcast
    func setPackageBroadcast(_ broadcast: Bool)
}

/// ESP-Touch version
public let ESPTOUCH_VERSION = "2.0.0"
