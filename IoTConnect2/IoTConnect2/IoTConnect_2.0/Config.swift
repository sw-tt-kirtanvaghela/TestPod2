//
//  Config.swift
//  IoTConnect

import Foundation

public enum CommandType:Int{
    case DEVICE_COMMAND = 0
    case OTA_COMMAND = 1
    case MODULE_COMMAND = 2
    case REFRESH_ATTRIBUTE = 101//"0x01"
    case FIRMWARE_UPDATE = 102//"0x02"
    case REFRESH_EDGE_RULE = 103
    case REFRESH_CHILD_DEVICE = 104
    case DATA_FREQUENCY_CHANGE = 105
    case DEVICE_DELETED = 106
    case DEVICE_DISABLED = 107
    case DEVICE_RELEASED = 108
    case STOP_OPERATION = 109
    case START_HEART_RATE = 110
    case STOP_HEART_RATE = 111
//    case SETTING_INFO_UPDATE = 111//"0x11"
    case PASSWORD_INFO_UPDATE = 112//"0x12"
    case DEVICE_INFO_UPDATE = 113//"0x13"
    case RULE_INFO_UPDATE = 115//"0x15"
    case DEVICE_CONNECTION_STATUS = 116//"0x16"
    case DATA_FREQUENCY_UPDATE = 117//"0x17"
    case STOP_SDK_CONNECTION = 199//"0x99"
    case IDENTITIY_RESPONSE = 200
    case GET_DEVICE_TEMPLATE_ATTRIBUTE = 201
    case GET_DEVICE_TEMPLATE_TWIN = 202
    case GET_EDGE_RULE = 203
    case GET_CHILD_DEVICE = 204
    case GET_PENDING_OTAS = 205
    case CREATE_DEVICE = 221
    case DELETE_DEVICE = 222
}

struct SDKURL {
    static let discoveryHost = "https://discovery.iotconnect.io"
    static let discoveryHostAWS = "https://54.160.162.148:219"
    static let endPointAWS = "?pf=aws"
    
    /**
    get the Discovery URL
     
    params:
     - strDiscoveryURL:You can find your associated discovery URL in the Key Vault of your account.If you do not find the discovery URL, your account will be using the default discovery URL
     https://discovery.iotconnect.io/
     - cpId:Provide a company identifier
     - lang:
     - ver:version of SDK
     - env:Device environment
     
     Returns:
     Returns the Discovery URL.
     */
    
    static func discovery(_ strDiscoveryURL:String, _ cpId:String, _ lang:String, _ ver:String, _ env:String,broker:BrokerType) -> String {
        //kirtan
       
        if broker == .aws{
            return String(format: "\(SDKURL.discoveryHostAWS)/api/v\(ver)/dsdk/cpid/\(cpId)/env/\(env)/\(endPointAWS)")
        }else{
            return String(format: "\(strDiscoveryURL)/api/v\(ver)/dsdk/cpid/\(cpId)/env/\(env)")
        }
    }
}

struct SDKConstants {
    static let developmentSDKYN = true //...For release SDK, this flag need to make false
    static let language = "M_ios"
    static let version = "2.1"
    static let protocolMQTT = "mqtt"
    static let protocolHTTP = "http"
    static let protocolAMQP = "amqp"
    static let frequencyDSC = 10.0
    static let isDebug = "isDebug"
    static let discoveryUrl = "discoveryUrl"
    static let certificate = "Certificate"
    static let password = "Password"
    static let sslPassword = ""
    static let osAvailSpaceInMb = 0
    static let osFileCount = 1
    static let osDisabled = false
    static let holdOfflineDataTime = 10.0
//    static let twinPropertyPubTopic = "$iothub/twin/PATCH/properties/reported/?$rid=1"
//    static let twinPropertySubTopic = "$iothub/twin/PATCH/properties/desired/#"
//    static let twinResponsePubTopic = "$iothub/twin/GET/?$rid=0"
//    static let twinResponseSubTopic = "$iothub/twin/res/#"
    static let aggrigacaseteType = ["min": 1, "max": 2, "sum": 4, "avg": 8, "count": 16, "lv": 32]
}

struct DataType {
    static let dtNumber = 0
    static let dtString = 1
    static let dtObject = 2
    static let dtFloat  = 3
}

struct AuthType {
    static let token = 1
    static let caSigned = 2
    static let caSelfSigned = 3
    static let symetricKey = 5
}

struct MessageType {
    static let rpt = 0
    static let flt = 1
    static let rptEdge = 2
    static let ruleMatchedEdge = 3
    static let log = 4
    static let ack = 5
    static let ota = 6
    static let custom = 7
    static let ping = 8
    static let deviceCreated = 9
    static let deviceStatus = 10
}

struct DeviceSync {
    struct Request {
        static let cpId = "cpId"
        static let uniqueId = "uniqueId"
        static let option = "option"
        static let attribute = "attribute"
        static let setting = "setting"
        static let protocolKey = "protocol"
        static let device = "device"
        static let sdkConfig = "sdkConfig"
        static let rule = "rule"
    }
    struct Response {
        static let ok = 0
        static let deviceNotRegistered = 1
        static let autoRegister = 2
        static let deviceNotFound = 3
        static let deviceInActive = 4
        static let objectMoved = 5
        static let cpidNotFound = 6
    }
}

struct SupportedDataType{
    static let nonObjVal      = 0
    static let intValue        = 1
    static let longVal        = 2
    static let decimalVal     = 3
    static let strVal         = 4
    static let timeVal        = 5
    static let dateValue      = 6
    static let dateTimeVal    = 7
    static let bitValue       = 8
    static let boolValue      = 9
    static let latLongVal     = 10
    static let objValue       = 12
}

struct DictAckKeys{
    static let dateKey = "dt"
    static let dataKey = "d"
    static let ackKey = "ack"
    static let typeKey = "type"
    static let statusKey = "st"
    static let messageKey = "msg"
    static let cidKey = "cid"
}

struct DictSyncresponseKeys{
    static let ecKey   = "ec"
    static let ctKey   = "ct"
    static let metaKey = "meta"
    static let hasKey  = "has"
    static let pKey    = "p"
}

struct DictMetaKeys{
    static let dfKey   = "df"
    static let cdKey   = "cd"
    static let atKey   = "at"
    static let gtwKey   = "gtw"
    static let tgKey   = "tg"
    static let gKey   = "g"
    static let edgeKey   = "edge"
    static let pfKey   = "pf"
    static let hwvKey   = "hwv"
    static let swvKey   = "swv"
    static let vKey   = "v"  
}

struct Dictkeys{
    static let cpIDkey      = "cpId"
    static let uniqueIDKey  = "uniqueId"
    static let tKey         = "t"
    static let mtKey        = "mt"
    static let dKey         = "d"
    static let sdkKey       = "sdk"
    static let languageKey  = "l"
    static let envKey       = "e"
    static let versionKey   = "v"
    static let dataKey      = "data"
    static let idkey        = "id"
    static let tagkey       = "tg"
    static let datekey      = "dt"
    static let gkey         = "g"
    static let errorkey     = "error"
    static let desireKey    = "desired"
    static let timeKey      = "time"
    static let dtgKey       = "dtg"
    static let hasKey       = "has"
    static let attrKey      = "attr"
    static let setKey       = "set"
    static let rulesKey     = "r"
    static let otaKey       = "ota"
    static let conditionValueKey   = "cv"
    static let subscriptionGUIDKey = "sg"
    static let commandTypeKey      = "ct"
    static let guidKey             = "guid"
    static let commandKey          = "command"
    static let ackKey              = "ack"
    static let ackIDKey            = "ackId"
    static let errorCodeKey        = "ec"
    static let ruleGUIDKey         = "rg"
    static let dataValidaionKey    = "dv"
    static let localNameKey        = "ln"
    static let rptdataKey          = "rptdata"
    static let medsageTypekey      = "mt"
    static let displayNamekey      = "dn"
    static let protocolkey         = "p"
    
}
