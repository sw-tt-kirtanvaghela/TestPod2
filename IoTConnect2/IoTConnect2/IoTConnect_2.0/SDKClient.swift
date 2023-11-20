//
//  IoTConnectSDK.swift
//  IoTConnect

import Foundation

public typealias GetDeviceCallBackBlock = (Any?) -> ()
public typealias OnTwinChangeCallBackBlock = (Any?) -> ()
public typealias GetAttributesCallbackBlock = (Any?) -> ()
public typealias GetTwinCallBackBlock = (Any?) -> ()
public typealias GetChildDevicesCallBackBlock = (Any?) -> ()
public typealias OnDeviceCommandCallBackBlock = (Any?) -> ()
public typealias OnAttributeChangeCallBackBlock = (Any?) -> ()
public typealias OnDeviceChangeCommandCallBackBlock = (Any?) -> ()
public typealias OnRuleChangeCommandCallBackBlock = (Any?) -> ()
public typealias OnOTACommandCallBackBlock = (Any?) -> ()
public typealias OnModuleCommandCallBackBlock = (Any?) -> ()
public typealias CreateChildDeviceCallBackBlock = (Any?) -> ()
public typealias DeleteChildDeviceCallBackBlock = (Any?) -> ()


public class SDKClient {
    // Singleton SDK object
    public static let shared = SDKClient()
    
    fileprivate var iotConnectManager: IoTConnectManager!// = IoTConnectManager.sharedInstance
    private var blockHandlerDeviceCallBack : GetDeviceCallBackBlock?
    private var blockHandlerTwinUpdateCallBack : OnTwinChangeCallBackBlock?
    private var blockHandlerGetAttributesCallBack : GetAttributesCallbackBlock?
    private var blockHandlerGetTwinsCallBack : GetTwinCallBackBlock?
    private var blockHandlerGetChildDevicesCallBack : GetChildDevicesCallBackBlock?
    private var blockHandlerOnDeviceCommand:OnDeviceCommandCallBackBlock?
    private var blockHandlerAttChnageCommand:OnAttributeChangeCallBackBlock?
    private var blockHandlerDeviceChnageCommand:OnDeviceChangeCommandCallBackBlock?
    private var blockHandlerRuleChangeCommand:OnRuleChangeCommandCallBackBlock?
    private var blockHandlerOTACommand:OnOTACommandCallBackBlock?
    private var blockHandlerModuleCommand:OnModuleCommandCallBackBlock?
    private var blockHandlerCreateChildCallBack:CreateChildDeviceCallBackBlock?
    private var blockHandlerDeleteChildCallBack:DeleteChildDeviceCallBackBlock?
    
    /**
     Initialize configuration for IoTConnect SDK
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - config: Setup IoTConnectConfig
     
     - returns:
     Returns nothing
     */
    public func initialize(config: IoTConnectConfig) {
        print("SDKClient initialize")
        iotConnectManager = IoTConnectManager(cpId: config.cpId, uniqueId: config.uniqueId, env: config.env.rawValue, sdkOptions: config.sdkOptions, deviceCallback: { (message) in
            if self.blockHandlerDeviceCallBack != nil {
                print("SDKClient blockHandlerDeviceCallBack")
                self.blockHandlerDeviceCallBack!(message)
            }
        }, twinUpdateCallback: { (twinMessage) in
            if self.blockHandlerTwinUpdateCallBack != nil {
                self.blockHandlerTwinUpdateCallBack!(twinMessage)
            }
        }, attributeCallBack: { (attributesMsg) in
            if self.blockHandlerGetAttributesCallBack != nil{
                self.blockHandlerGetAttributesCallBack!(attributesMsg)
            }
        }, twinsCallBack: { (twinsMsg) in
            if self.blockHandlerGetTwinsCallBack != nil{
                self.blockHandlerGetTwinsCallBack!(twinsMsg)
            }
        }, getChildCallback: { (msg) in
            if self.blockHandlerGetChildDevicesCallBack != nil{
                self.blockHandlerGetChildDevicesCallBack!(msg)
            }
        })
        
        iotConnectManager.callBackDelegate = self
    }
    
    /**
     Used for sending data from Device to Cloud
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: Provide data in [[String:Any]] format
     
     - returns:
     Returns nothing
     */
    public func sendData(data: [String:Any]) {
        iotConnectManager.sendData(data: data)
    }
    
    /**
     Used for sending log from device to cloud
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: send log in [String: Any] format
     
     - returns:
     Returns nothing
     */
    public func sendLog(data: [String: Any]?) {
        iotConnectManager.sendLog(data: data)
    }
    
    /**
     Send acknowledgement signal
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: send data in [[String:Any]] format
     - msgType: send msgType from anyone of this
     
     - returns:
     Returns nothing
     */
    public func sendAck(data: [[String:Any]], msgType: String) {
        iotConnectManager.sendAck(data: data, msgType: msgType)
    }
    
    //send ack for device command
    public func sendAckCmd(ackGuid:String,status:String, msg:String = "",childId:String = "") {
        iotConnectManager.sendAckCmd(ackGuid: ackGuid, status: status,msg: msg,childId: childId, type: 0)
    }
    
    //send ack for OTA command
    public func  sendOTAAckCmd(ackGuid:String,status:String, msg:String = "",childId:String = "") {
        iotConnectManager.sendAckCmd(ackGuid: ackGuid, status: status,msg: msg,childId: childId, type: 1)
    }
    
    //send ack for module command
    public func sendAckModule(ackGuid:String,status:String, msg:String = "",childId:String = "") {
        iotConnectManager.sendAckCmd(ackGuid: ackGuid, status: status,msg: msg,childId: childId, type: 2)
    }

    /**
     Get all twins
     
     - Author:
     Devesh Mevada
     
     - returns:
     Returns nothing
     */
    public func getAllTwins() {
        iotConnectManager.getAllTwins()
    }
    
    /**
     Updated twins
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - key: key in String format
     - value: value as any
     
     - returns:
     Returns nothing
     */
    public func updateTwin(key: String, value: Any) {
        iotConnectManager.updateTwin(key: key, value: value)
    }
    
    /**
     Dispose description
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - sdkconnection: description
     
     - returns:
     Returns nothing
     */
    public func dispose(sdkconnection: String = "") {
        iotConnectManager.dispose(sdkconnection: sdkconnection)
    }
    
    /**
     Get attaributs
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func getAttributes(callBack: @escaping GetAttributesCallbackBlock) -> () {
        blockHandlerGetAttributesCallBack = callBack
        iotConnectManager?.getAttributes(callBack: callBack)
    }
    
    //get twins
    public func getTwins(callBack: @escaping GetTwinCallBackBlock) -> () {
        blockHandlerGetTwinsCallBack = callBack
        iotConnectManager.getTwins(callBack: callBack)
    }
    
    //Get child devices
    public func getChildDevices(callBack: @escaping GetChildDevicesCallBackBlock) -> () {
        blockHandlerGetChildDevicesCallBack = callBack
        iotConnectManager?.getChildDevices(callBack: callBack)
    }
    

    /**
     Get device callback
     
     - Author:
     Keyur Prajapati
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func getDeviceCallBack(deviceCallback: @escaping GetDeviceCallBackBlock) -> () {
        blockHandlerDeviceCallBack = deviceCallback
    }
    
    //Device command cloud to device call back
    public func onDeviceCommand(commandCallback:@escaping OnDeviceCommandCallBackBlock){
        blockHandlerOnDeviceCommand = commandCallback
    }
    
    //Refresh attribute cloud to device command callback
    public func onAttrChangeCommand(commandCallback:@escaping OnAttributeChangeCallBackBlock){
        blockHandlerAttChnageCommand = commandCallback
    }
    
    //Refresh child device cloud to device callback
    public func onDeviceChangeCommand(commandCallback:@escaping OnDeviceChangeCommandCallBackBlock){
        blockHandlerDeviceChnageCommand = commandCallback
    }
    
    //Refresh edge rule cloud to device command
    public func onRuleChangeCommand(commandCallback:@escaping OnRuleChangeCommandCallBackBlock){
        blockHandlerRuleChangeCommand = commandCallback
    }
    
    //OTA command cloud to device callback
    public func onOTACommand(commandCallback:@escaping OnOTACommandCallBackBlock){
        blockHandlerOTACommand = commandCallback
    }
    
    //Module command cloud to device command
    public func onModuleCommand(commandCallback:@escaping OnDeviceCommandCallBackBlock){
        blockHandlerModuleCommand = commandCallback
    }
    
    /**
     Get twin callback
     
     - Author:
     Keyur Prajapati
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func onTwinChangeCommand(twinUpdateCallback: @escaping OnTwinChangeCallBackBlock) -> () {
        blockHandlerTwinUpdateCallBack = twinUpdateCallback
    }
    
    //Data frequency change command
    public func onFrequencyChangeCommand(dfValue:Int){
        iotConnectManager?.onFrequencyChangeCommand(dfValue: dfValue)
    }
    
    func onHeartbeatCommand(isStart:Bool,df:Int = 0){
        if isStart{
            iotConnectManager.startHeartRate(df: Double(df))
        }else{
            iotConnectManager.stopHeartRate()
        }
    }
    
    func onHardStopCommand(){
        
    }
    
    //Create child device callback
    public func createChildDevice(deviceId:String, deviceTag:String, displayName:String,createChildCallBack:@escaping CreateChildDeviceCallBackBlock) -> (){
        iotConnectManager?.createChildDevice(deviceId: deviceId, deviceTag: deviceTag, displayName: displayName)
        blockHandlerCreateChildCallBack = createChildCallBack
    }
    
    //Delete child device callback
    public func deleteChildDevice(deviceId:String, deleteChildCallBack:@escaping DeleteChildDeviceCallBackBlock)-> (){
        iotConnectManager?.deleteChildDevice(uniqueID: deviceId)
        blockHandlerDeleteChildCallBack = deleteChildCallBack
    }
    
    //get error messge for delete device from error code
    func getErrorMsgForDeleteDevice(code:Int)->String{
        if code == 1{
            return "Child device not found"
        }
        return "Something went wrong"
    }
    
    //get error messge for create device from error code
    func getErrorMsgForCreateDevice(code:Int)->String{
        switch code{
         
        case 1:
            return "Message missing child tag"
        case 2:
            return "Message missing child device uniqueid"
        case 3:
            return "Message missing child device display name"
        case 4:
            return "Gateway device not found"
        case 5:
            return "Could not create device, something went wrong"
        case 6:
            return "Child device tag is not valid"
        case 7:
            return "Child device tag name cannot be same as Gateway device"
        case 8:
            return "Child uniqueid is already exists."
        case 9:
            return "Child uniqueid should not exceed 128 characters"
        default:
            return "Something went wrong"
        }
        
    }
    
}


extension SDKClient : callBackResponse{
    
    func onDeviceDeleteCommand(response: [String : Any]) {
        let dict = response[Dictkeys.dKey] as? [String:Any]
        let ec = dict?[Dictkeys.errorCodeKey] as? Int
        if ec == 0{
            blockHandlerDeleteChildCallBack?(response)
        }else{
            let error = getErrorMsgForDeleteDevice(code: ec ?? 0)
            blockHandlerDeleteChildCallBack?(error)
        }
    }
    
    func onCreateChildDevice(response: [String : Any]) {
        let dict = response[Dictkeys.dKey] as? [String:Any]
        let ec = dict?[Dictkeys.errorCodeKey] as? Int
        if ec == 0{
            blockHandlerCreateChildCallBack?(response)
        }else{
            let error = getErrorMsgForCreateDevice(code: ec ?? 0)
            blockHandlerCreateChildCallBack?(error)
        }
    }
    
    func onModuleCommand(response: [String : Any]) {
        blockHandlerModuleCommand?(response)
    }
    
    func onOTACommand(response: [String : Any]) {
        blockHandlerOTACommand?(response)
    }
    
    func onRuleChangeCommand(response: [String : Any]) {
        blockHandlerRuleChangeCommand?(response)
    }
    
    func onDeviceChangeCommand(response: [String : Any]) {
        blockHandlerDeviceChnageCommand?(response)
    }
    
    func onAttrChangeCommand(response: [String : Any]) {
        blockHandlerAttChnageCommand?(response)
    }
    
    func onDeviceCommandCallback(response:[String:Any]?,error:String?) {
        print("onDeviceCommandCallback called \(response ?? [:])")
        blockHandlerOnDeviceCommand?(response)
    }
}
