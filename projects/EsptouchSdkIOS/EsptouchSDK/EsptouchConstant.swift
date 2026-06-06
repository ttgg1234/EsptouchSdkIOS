import Foundation

/// ESP-Touch Protocol Constants
public struct EsptouchConstant {
    /// ESP-Touch Version
    public static let ESPTOUCH_VERSION = "2.0.0"
    
    /// The length of the guide code
    public static let GUIDE_CODE_LEN = 4
    
    /// The length of the total data
    public static let TOTAL_DATA_LEN = 9
    
    /// The length of the data code
    public static let DATA_CODE_LEN = TOTAL_DATA_LEN - GUIDE_CODE_LEN
    
    /// The timeout for waiting UDP response (milliseconds)
    public static var WAIT_UDP_TIME_MILLIS: Int = 15000
    
    /// The timeout for waiting UDP response after device connected (milliseconds)
    public static var WAIT_UDP_TIME_MILLIS_DEVCONN: Int = 8000
    
    /// The interval for sending UDP broadcast (milliseconds)
    public static var BROADCAST_INTERVAL_MILLIS: Int = 8
    
    /// The port for listening UDP response
    public static let PORT_LISTENING: Int = 18266
    
    /// The port for sending UDP broadcast
    public static let PORT_TARGET: Int = 7001
    
    /// The total expect results count
    public static let EXPECT_TASK_RESULT_COUNT: Int = 1
    
    /// The threshold count for success broadcast
    public static let THRESHOLD_SUC_BROADCAST_COUNT: Int = 1
    
    /// The length of the SSID
    public static let SSID_LEN = 32
    
    /// The length of the BSSID
    public static let BSSID_LEN = 6
    
    /// The length of the password
    public static let PASSWORD_MAX_LEN = 64
    
    /// The magic number
    public static let MAGIC_NUMBER: UInt8 = 0xE0
    
    /// The total length of characters in one time of sending
    public static let TOTAL_LENGTH: Int = 14
    
    /// The length of the header of Esptouch v2
    public static let HEADER_LEN: Int = 2
    
    /// The length of the salt
    public static let SALT_LEN: Int = 4
    
    /// The length of the verify number
    public static let VERIFY_NUM_LEN: Int = 4
    
    /// The length of the AES key
    public static let AES_KEY_LEN: Int = 16
}
