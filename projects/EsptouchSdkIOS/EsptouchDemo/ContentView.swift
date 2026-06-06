import SwiftUI
import EsptouchSDK

struct ContentView: View {
    @State private var wifiName: String = ""
    @State private var wifiPassword: String = ""
    @State private var logText: String = ""
    @State private var isProvisioning: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                Text("ESP-Touch")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("WiFi Provisioning")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            
            // Info text
            Text("此设备仅支持 2.4GHz WiFi，配网前请将设备通电，并确认指示灯进入慢闪状态")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            // Input fields
            VStack(spacing: 16) {
                TextField("请输入WiFi账号", text: $wifiName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("请输入WiFi密码", text: $wifiPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: startProvisioning) {
                    HStack {
                        if isProvisioning {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isProvisioning ? "配网中..." : "WiFi配网")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProvisioning ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isProvisioning || wifiName.isEmpty || wifiPassword.isEmpty)
            }
            .padding(.horizontal, 30)
            
            // Log area
            VStack(alignment: .leading) {
                HStack {
                    Text("日志")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView {
                    Text(logText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color(hex: "07F642"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
                .background(Color.black)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            refreshWifiInfo()
        }
    }
    
    private func startProvisioning() {
        guard !wifiName.isEmpty, !wifiPassword.isEmpty else {
            return
        }
        
        isProvisioning = true
        appendLog("正在获取WiFi信息...")
        
        // Get current WiFi BSSID
        let bssid = getWiFiBSSID() ?? "00:00:00:00:00:00"
        appendLog("当前WiFi BSSID: \(bssid)")
        appendLog("正在开始WIFI配置...")
        
        Esptouch.startProvision(
            ssid: wifiName,
            bssid: bssid,
            password: wifiPassword,
            timeout: 60000
        ) { result in
            DispatchQueue.main.async {
                self.isProvisioning = false
                
                switch result {
                case .success(let results):
                    if let firstResult = results.first {
                        if firstResult.isSuc() {
                            self.appendLog("WIFI配置成功!")
                            self.appendLog("设备BSSID: \(firstResult.getBssid() ?? "N/A")")
                            self.appendLog("设备IP: \(firstResult.getInetAddress() ?? "N/A")")
                            self.alertMessage = "WiFi配网成功!"
                        } else {
                            self.appendLog("WIFI配置失败")
                            self.alertMessage = "WiFi配网失败，请重试"
                        }
                    } else {
                        self.appendLog("WIFI配置超时")
                        self.alertMessage = "WiFi配网超时，请确保设备已进入配网模式"
                    }
                    self.showingAlert = true
                    
                case .failure(let error):
                    self.appendLog("错误: \(error.localizedDescription)")
                    self.alertMessage = "配网失败: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func refreshWifiInfo() {
        appendLog("Wifi初始化...")
        
        if let ssid = getWiFiSSID() {
            wifiName = ssid
            appendLog("当前WiFi名称: \(ssid)")
        } else {
            appendLog("未检测到WiFi连接")
        }
    }
    
    private func appendLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logText = "[\(timestamp)] \(message)\n" + logText
    }
    
    private func getWiFiSSID() -> String? {
        #if targetEnvironment(simulator)
        return "Simulator-WiFi"
        #else
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                    ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
        #endif
    }
    
    private func getWiFiBSSID() -> String? {
        #if targetEnvironment(simulator)
        return "00:00:00:00:00:00"
        #else
        var bssid: String?
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                    bssid = networkInfo[kCNNetworkInfoKeyBSSID as String] as? String
                    break
                }
            }
        }
        return bssid
        #endif
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
