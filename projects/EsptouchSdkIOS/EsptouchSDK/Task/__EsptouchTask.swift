import Foundation

/// Internal ESP-Touch task implementation
class __EsptouchTask {
    
    private let TAG = "__EsptouchTask"
    
    private let socketClient: UDPSocketClient
    private let socketServer: UDPSocketServer
    private let apSsid: [UInt8]
    private let apPassword: [UInt8]
    private let apBssid: [UInt8]
    private let parameter: EsptouchTaskParameter
    
    private var isInterrupt: Bool = false
    private var isExecuted: Bool = false
    private var isCancelled: Bool = false
    private var esptouchResultList: [IEsptouchResult] = []
    private var bssidTaskSucCountMap: [String: Int] = [:]
    private var listener: IEsptouchListener?
    private var taskThread: Thread?
    
    /// Initialize the task
    /// - Parameters:
    ///   - apSsid: SSID data
    ///   - apBssid: BSSID data
    ///   - apPassword: Password data
    ///   - espAES: AES encryption (optional)
    ///   - parameter: Task parameters
    init(apSsid: [UInt8], apBssid: [UInt8], apPassword: [UInt8], 
         espAES: EspAES?, parameter: EsptouchTaskParameter) {
        
        self.apSsid = espAES != nil ? espAES!.encrypt(apSsid) : apSsid
        self.apPassword = espAES != nil ? espAES!.encrypt(apPassword) : apPassword
        self.apBssid = apBssid
        self.parameter = parameter
        
        self.socketClient = UDPSocketClient()
        self.socketServer = UDPSocketServer(
            port: parameter.getPortListening(),
            timeout: parameter.getWaitUdpTotalMillisecond()
        )
    }
    
    /// Interrupt the task
    func interrupt() {
        isCancelled = true
        __interrupt()
    }
    
    /// Check if cancelled
    func isCancelled() -> Bool {
        return isCancelled
    }
    
    /// Execute and return single result
    func executeForResult() -> IEsptouchResult? {
        let results = executeForResults(1)
        return results.first
    }
    
    /// Execute and return multiple results
    /// - Parameter expectTaskResultCount: Expected result count
    /// - Returns: Array of results
    func executeForResults(_ expectTaskResultCount: Int) -> [IEsptouchResult] {
        if isExecuted {
            return esptouchResultList.isEmpty ? [createFailResult()] : esptouchResultList
        }
        
        isExecuted = true
        
        // Set expected result count
        parameter.setExpectTaskResultCount(expectTaskResultCount > 0 ? expectTaskResultCount : 1)
        
        // Start listening asynchronously
        __listenAsyn()
        
        // Send data in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.__sendData()
        }
        
        // Wait for results or timeout
        let timeout = parameter.getWaitUdpTotalMillisecond() / 1000
        for _ in 0..<(timeout * 10) {
            if isInterrupt || !esptouchResultList.isEmpty {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if esptouchResultList.isEmpty {
            return [createFailResult()]
        }
        
        return esptouchResultList
    }
    
    /// Set listener for results
    func setEsptouchListener(_ listener: IEsptouchListener?) {
        self.listener = listener
    }
    
    private func __interrupt() {
        guard !isInterrupt else { return }
        isInterrupt = true
        socketClient.interrupt()
        socketServer.interrupt()
        taskThread?.cancel()
    }
    
    private func __sendData() {
        let generator = EsptouchGenerator(apSsid: apSsid, apBssid: apBssid, apPassword: apPassword)
        let broadcastData = generator.generateBroadcastData()
        
        let targetHost = EspNetUtil.getBroadcastAddress()
        let interval = parameter.getBroadcastInterval()
        let port = EsptouchConstant.PORT_TARGET
        
        // Send data packets repeatedly
        let maxWaitTime = parameter.getWaitUdpTotalMillisecond()
        let startTime = Date()
        
        while !isInterrupt && Int(Date().timeIntervalSince(startTime) * 1000) < maxWaitTime {
            socketClient.sendData(broadcastData, targetHost: targetHost, targetPort: port, interval: interval)
        }
    }
    
    private func __listenAsyn() {
        taskThread = Thread { [weak self] in
            self?.__listen()
        }
        taskThread?.start()
    }
    
    private func __listen() {
        let expectOneByte: UInt8 = UInt8(apSsid.count + apPassword.count + 9)
        let expectDataLen = 1
        
        let startTimestamp = Date()
        
        while esptouchResultList.count < parameter.getExpectTaskResultCount() && !isInterrupt {
            guard let receiveBytes = socketServer.receiveSpecLenBytes(expectDataLen) else {
                continue
            }
            
            if receiveBytes.isEmpty {
                continue
            }
            
            let receiveOneByte = receiveBytes[0]
            
            if receiveOneByte == expectOneByte {
                // Calculate remaining timeout
                let consume = Int(Date().timeIntervalSince(startTimestamp) * 1000)
                var timeout = parameter.getWaitUdpTotalMillisecond() - consume
                
                if timeout < 0 {
                    break
                }
                
                socketServer.setSoTimeout(timeout)
                
                // Receive full data
                if let fullData = socketServer.receiveSpecLenBytes(9), fullData.count >= 6 {
                    // Parse BSSID from response
                    let bssid = parseBssidFromResponse(fullData)
                    let inetAddress = "192.168.1.1" // Placeholder, actual implementation needs more parsing
                    
                    __putEsptouchResult(isSuc: true, bssid: bssid, inetAddress: inetAddress)
                }
            }
        }
    }
    
    private func parseBssidFromResponse(_ data: [UInt8]) -> String {
        guard data.count >= 6 else { return "" }
        let bytes = Array(data.prefix(6))
        return bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
    }
    
    private func __putEsptouchResult(isSuc: Bool, bssid: String, inetAddress: String) {
        guard !bssid.isEmpty else { return }
        
        // Check threshold
        let count = (bssidTaskSucCountMap[bssid] ?? 0) + 1
        bssidTaskSucCountMap[bssid] = count
        
        let isTaskSucCountEnough = count >= parameter.getThresholdSucBroadcastCount()
        
        if !isTaskSucCountEnough {
            return
        }
        
        // Check if already exists
        for result in esptouchResultList {
            if result.getBssid() == bssid {
                return
            }
        }
        
        let result = EsptouchResult(isSuc: isSuc, bssid: bssid, inetAddress: inetAddress)
        esptouchResultList.append(result)
        
        DispatchQueue.main.async { [weak self] in
            self?.listener?.onEsptouchResultAdded(result)
        }
    }
    
    private func createFailResult() -> IEsptouchResult {
        let result = EsptouchResult(isSuc: false, bssid: nil, inetAddress: nil)
        result.setIsCancelled(isCancelled)
        return result
    }
}
