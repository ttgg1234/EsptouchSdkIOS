import Foundation

/// Main ESP-Touch Task class for WiFi provisioning
public class EsptouchTask: IEsptouchTask {
    
    private var esptouchTask: __EsptouchTask?
    private var parameter: EsptouchTaskParameter
    
    /// Initialize with string credentials
    /// - Parameters:
    ///   - apSsid: WiFi SSID
    ///   - apBssid: WiFi BSSID
    ///   - apPassword: WiFi Password
    public convenience init(apSsid: String, apBssid: String, apPassword: String) {
        self.init(apSsid: apSsid, apBssid: apBssid, apPassword: apPassword, espAES: nil)
    }
    
    /// Initialize with string credentials and AES key
    /// - Parameters:
    ///   - apSsid: WiFi SSID
    ///   - apBssid: WiFi BSSID
    ///   - apPassword: WiFi Password
    ///   - espAES: AES encryption key
    public init(apSsid: String, apBssid: String, apPassword: String, espAES: EspAES?) {
        precondition(!apSsid.isEmpty, "SSID can't be empty")
        precondition(!apBssid.isEmpty, "BSSID can't be empty")
        
        let ssidData = TouchData(apSsid).getData()
        let bssidData = EspNetUtil.parseBssid2bytes(apBssid)
        let passwordData = TouchData(apPassword).getData()
        
        parameter = EsptouchTaskParameter()
        esptouchTask = __EsptouchTask(
            apSsid: ssidData,
            apBssid: bssidData,
            apPassword: passwordData,
            espAES: espAES,
            parameter: parameter
        )
    }
    
    /// Initialize with byte credentials
    /// - Parameters:
    ///   - apSsid: SSID bytes
    ///   - apBssid: BSSID bytes
    ///   - apPassword: Password bytes
    public convenience init(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8]) {
        self.init(apSsid: apSsid, apBssid: apBssid, apPassword: apPassword, espAES: nil)
    }
    
    /// Initialize with byte credentials and AES key
    /// - Parameters:
    ///   - apSsid: SSID bytes
    ///   - apBssid: BSSID bytes
    ///   - apPassword: Password bytes
    ///   - espAES: AES encryption key
    public init(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8], espAES: EspAES?) {
        precondition(!apSsid.isEmpty, "SSID can't be empty")
        precondition(!apBssid.isEmpty, "BSSID can't be empty")
        
        parameter = EsptouchTaskParameter()
        esptouchTask = __EsptouchTask(
            apSsid: apSsid,
            apBssid: apBssid,
            apPassword: apPassword,
            espAES: espAES,
            parameter: parameter
        )
    }
    
    public func interrupt() {
        esptouchTask?.interrupt()
    }
    
    public func executeForResult() -> IEsptouchResult? {
        return esptouchTask?.executeForResult()
    }
    
    public func isCancelled() -> Bool {
        return esptouchTask?.isCancelled() ?? false
    }
    
    public func executeForResults(_ expectTaskResultCount: Int) -> [IEsptouchResult] {
        return esptouchTask?.executeForResults(expectTaskResultCount) ?? []
    }
    
    public func setEsptouchListener(_ listener: IEsptouchListener) {
        esptouchTask?.setEsptouchListener(listener)
    }
    
    public func setPackageBroadcast(_ broadcast: Bool) {
        parameter.setBroadcast(broadcast)
    }
}
