//
//  ErrosLog.swift
//  IoTConnect

import Foundation

enum GenericErrors: Error {
    case unknownError
    case noInternetConnection
    case requestTimeout
    case invalidJson
    case unableToCreateRequest
    case emptyData
    case unacceptableStatusCode
    case unableToDecode
}

struct Log {//class
    enum Errors: String {
        case ERR_IN01 = "<<Exception error message>>"
        case ERR_IN02 = "Discovery URL can not be blank"
        case ERR_IN06 = "SDK options : set proper certificate file path and try again"
        case ERR_IN09 = "Unable to get baseUrl"
        case ERR_IN10 = "Device information not found"
        case ERR_IN11 = "Device broker information not found"
        case ERR_IN14 = "Client connection closed"
        case ERR_SD02 = "It does not matched with payload's 'uniqueId'"
        case ERR_SD06 = "Missing required parameter 'data'"
        case ERR_SD10 = "Publish data failed : MQTT connection not found"
        case ERR_TP01 = "<<Exception error message>>  "
        case ERR_TP02 = "Device is barred updateTwin() method is not permitted"
        case ERR_TP03 = "Missing required parameter 'key' or 'value' to update twin property"
        case ERR_TP04 = "Device is barred getAllTwins() method is not permitted"
        case ERR_CM01 = "<<Exception error message>>   "
        case ERR_CM02 = "Missing required parameter 'data' or 'msgType' to send acknowledgement"
        case ERR_CM04 = "Device is barred SendAck() method is not permitted"
        case ERR_OS01 = " <<Exception error message>>"
        case ERR_OS04 = "Unable to scan directory"
        case ERR_DC02 = "Connection not available"
        case ERR_GA02 = "Attributes data not found"
        case ERR_GA03 = "Twins data not found"
        case ERR_GA04 = "Child devices data not found"
        case ERR_PS01 = "JSON parsing error"    //...New
        case ERR_1     = "Device not found. Device is not whitelisted to                        platform"
        case ERR_2     = "Device is not active"
        case ERR_3     = "Un-Associated. Device has not any template associated with it"
        case ERR_4     = "Device is not acquired. Device is created but it is in release state"
        case ERR_5     = "Device is disabled. It’s disabled from IoTHub by Platform Admin"
       case ERR_6      = "Company not found as SID is not valid"
       case ERR_7     = "Subscription is expired"
       case ERR_8     = "Connection Not Allowed"
       case ERR_9     = "Invalid Bootstrap Certificate"
       case ERR_10    = "Invalid Operational Certificate"
    }
    enum Info: String {
        case INFO_IN01 = "Device information received successfully"
        case INFO_IN02 = "Device connected"
        case INFO_IN03 = "Device disconnected"
        case INFO_IN04 = "Initializing..."
        case INFO_IN05 = "Connecting..."
        case INFO_IN06 = "Rechecking..."
        case INFO_IN07 = "BaseUrl received to sync the device information"
        case INFO_IN08 = "Response Code : 0 'OK'"
        case INFO_IN09 = "Response Code : 1 'DEVICE_NOT_REGISTERED'"
        case INFO_IN10 = "Response Code : 2 'AUTO_REGISTER'"
        case INFO_IN11 = "Response Code : 3 'DEVICE_NOT_FOUND'"
        case INFO_IN12 = "Response Code : 4 'DEVICE_INACTIVE'"
        case INFO_IN13 = "Response Code : 5 'OBJECT_MOVED'"
        case INFO_IN14 = "Response Code : 6 'CPID_NOT_FOUND'"
        case INFO_IN15 = "Response Code : 'NO_RESPONSE_CODE_MATCHED'"
        case INFO_SD01 = "Publish data"
        case INFO_TP01 = "Twin property updated successfully"
        case INFO_TP02 = "Request sent successfully to get the all twin properties."
        case INFO_CM01 = "Command : 0x01 : STANDARD_COMMAND"
        case INFO_CM02 = "Command : 0x02 : FIRMWARE_UPDATE"
        case INFO_CM03 = "Command : 101 : ATTRIBUTE_UPDATE"
        case INFO_CM04 = "Command : 0x11 : SETTING_UPDATE"
        case INFO_CM05 = "Command : 0x12 : PASSWORD_UPDATE"
        case INFO_CM06 = "Command : 0x13 : DEVICE_UPDATE"
        case INFO_CM08 = "Command : 0x99 : STOP_SDK_CONNECTION"
        case INFO_CM10 = "Command acknowledgement success"
        case INFO_CM11 = "Command : 0x17 : DATA_FREQUENCY_UPDATE"
        case INFO_OS02 = "Offline data saved"
        case INFO_OS03 = "File has been created to store offline data"
        case INFO_OS04 = "Offline log file deleted"
        case INFO_OS05 = "No offline data found"
        case INFO_OS06 = "Offline data publish :: Send/Total :: "
        case INFO_DC01 = "Device already disconnected"
        case INFO_GA01 = "Get attributes successfully"
        case INFO_GA02 = "Get twind successfully"
        case INFO_GA03 = "Get child devices successfully"
    }
    
    static func getAPIErrorMsg(errorCode:Int)->String{
        switch errorCode{
            case 1:
                return  Log.Errors.ERR_1.rawValue
            case 2:
                return Log.Errors.ERR_2.rawValue
            case 3:
                return Log.Errors.ERR_3.rawValue
            case 4:
                return Log.Errors.ERR_4.rawValue
            case 5:
                return Log.Errors.ERR_5.rawValue
            case 6:
                return Log.Errors.ERR_6.rawValue
            case 7:
                return Log.Errors.ERR_7.rawValue
            case 8:
                return Log.Errors.ERR_8.rawValue
            case 9:
                return Log.Errors.ERR_9.rawValue
            case 10:
                return Log.Errors.ERR_10.rawValue
            default:
            return "Error"
        }
    }
    
}

