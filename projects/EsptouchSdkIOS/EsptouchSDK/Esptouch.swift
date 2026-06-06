import Foundation

/// ESP-Touch SDK Public API
public class Esptouch {
    
    /// Start WiFi provisioning
    /// - Parameters:
    ///   - ssid: WiFi SSID
    ///   - bssid: WiFi BSSID
    ///   - password: WiFi Password
    ///   - timeout: Timeout in milliseconds
    ///   - completion: Completion handler with results
    public static func startProvision(
        ssid: String,
        bssid: String,
        password: String,
        timeout: Int = 60000,
        completion: @escaping (Result<[IEsptouchResult], Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let task = EsptouchTask(apSsid: ssid, apBssid: bssid, apPassword: password)
                let results = task.executeForResults(1)
                DispatchQueue.main.async {
                    completion(.success(results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
