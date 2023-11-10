//
//  IoTConnectService.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation
import UIKit
import CommonCrypto

extension IoTConnectManager {
    
    //MARK: - Instance Methods
    
    /**
    - initialize IoTConnectManager
     
    - parameters:
        - cpId: comoany ID
        - uniqueId:Device unique identifier
        - deviceCallback
        - twinUpdateCallback
    
     - Returns
        returns nothing
     */
    func initialize(cpId: String, uniqueId: String, deviceCallback: @escaping GetDeviceCallBackBlock, twinUpdateCallback: @escaping GetDeviceCallBackBlock, getAttributesCallback: @escaping GetAttributesCallbackBlock, getTwinsCallback: @escaping GetTwinCallBackBlock, getChildDevucesCallback: @escaping GetChildDevicesCallBackBlock) {
        dictReference = [:]
        dictSyncResponse = [:]
        blockHandlerDeviceCallBack = deviceCallback
        blockHandlerTwinUpdateCallBack = twinUpdateCallback
        blockHandlerGetAttribuesCallBack = getAttributesCallback
        blockHandlerGetTwinsCallBack = getTwinsCallback
        blockHandlerGetChildDevicesCallback = getChildDevucesCallback
        boolCanCallInialiseYN = true
        objCommon.createDirectoryFoldersForLogs()
        objCommon.manageDebugLog(code: Log.Info.INFO_IN04, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
        objCommon.getBaseURL(strURL: SDKURL.discovery(strDiscoveryURL, cpId, SDKConstants.language, SDKConstants.version, strEnv.rawValue,broker:dataSDKOptions.brokerType ?? BrokerType.az)) { (status, data) in
            if status {
                if let dataRef = data as? [String : Any] {
                    self.objCommon.manageDebugLog(code: Log.Info.INFO_IN07, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                    self.dictReference = dataRef
                    if self.dictReference[keyPath:"d.ec"] as? Int == 0{
                        self.initaliseCall(uniqueId: uniqueId)
                    }else{
                        let errorDict = [Dictkeys.errorkey:Log.getAPIErrorMsg(errorCode: self.dictReference[keyPath:"d.ec"] as? Int ?? 15)]
                        deviceCallback(errorDict)
                        self.objCommon.manageDebugLog(code: self.dictReference[keyPath:"d.ec"] ?? 15, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                    }
                } else {
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN09, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            } else {
                if let error = data as? Error {
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: uniqueId, cpId: cpId, message: error.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            }
        }
    }
    
    /**
    - initialize initaliseCall
     
    - parameters:
        - uniqueId:Device unique identifier
      
     - Returns
        returns nothing
     */
    
    private func initaliseCall( uniqueId: String) {
        if boolCanCallInialiseYN {
            boolCanCallInialiseYN = false
            dictSyncResponse.removeAll()
            //kirtan
            let bu = dictReference[keyPath:"d.bu"]//d?["bu"]
            objCommon.makeSyncCall(withBaseURL: (bu as? String ?? "") + "/uid/"+"\(uniqueId)", withData: [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.attribute: true, DeviceSync.Request.setting: true, DeviceSync.Request.protocolKey: true, DeviceSync.Request.device: true, DeviceSync.Request.sdkConfig: true, DeviceSync.Request.rule: true]]) { (data, response, error) in
                
                self.blockHandlerDeviceCallBack?(data)
                if error == nil {
                    let errorParse: Error? = nil
         
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    
                    
                    if dataDeviceTemp == nil {
                        
                        print("Error parsing DSC: \(String(describing: errorParse))")
                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_PS01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: errorParse?.localizedDescription ?? "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                        self.blockHandlerDeviceCallBack(["sdkStatus": "error"])
                    } else {
                        let dataDevice = dataDeviceTemp as! [String:Any]
                       
                        if let jsonData = try? JSONDecoder().decode(Identity.self, from: data!) {
                            self.identity = jsonData
                        } else {
                          print("Error parsing syncCall Response")
                        }
                        if dataDevice[Dictkeys.dKey] != nil {
                            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                            print("identity pos data\(String(describing: self.identity?.d?.has))")
                            if SDKConstants.developmentSDKYN {
                                print("blockHandlerDeviceCallBack initialise call \(dataDevice)")
                                self.blockHandlerDeviceCallBack(["sdkStatus": "success", "data": dataDevice["d"]])
                            }
                            if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.ok {//...OK
                                
                                if !self.dataSDKOptions.offlineStorage.disabled {
                                    self.objCommon.createPredeffinedLogDirecctories(folderName: "logs/offline/\(self.strCPId!)_\(self.strUniqueId!)")
                                }
                                
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN08, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister != nil {
                                    self.timerNotRegister?.invalidate()
                                    self.timerNotRegister = nil
                                }
                              
                                self.dictSyncResponse = dataDevice[Dictkeys.dKey] as? [String : Any]
//                                self.getAttributes { isSuccess, data, msg in
//
//                                }
                                let metaInfo = self.dictSyncResponse[DictSyncresponseKeys.metaKey] as? [String:Any]
                                
                                if metaInfo?[DictMetaKeys.atKey] as! Int == AuthType.caSigned || metaInfo?[DictMetaKeys.atKey] as! Int == AuthType.caSelfSigned && !self.certPathFlag {
                                    
                                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN06, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                                    
                                }else if metaInfo?[DictMetaKeys.atKey] as! Int == AuthType.symetricKey{
                                    let resourceUrl = "\(dataDevice[keyPath: "d.p.h"] ?? "")/devices/\(dataDevice[keyPath: "d.p.id"] ?? "")"
                                    print("resourceUrl \(resourceUrl) \(self.dataSDKOptions.devicePK)")
                                    let token = try! self.generateSasToken(resourceUri: resourceUrl, key: self.dataSDKOptions.devicePK)
                                    print("Generated token \(token)")
                                    self.startMQTTCall(dataSyncResponse: self.dictSyncResponse,password: token)
                                }
                                else {
                                    if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolMQTT {
                                        //...Here
                                        self.startMQTTCall(dataSyncResponse: self.dictSyncResponse)
                                    } else if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolHTTP {
                                        
                                    } else if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolAMQP {
                                        
                                    }
                                }
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.deviceNotRegistered {//...Not Register
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN09, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.frequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.autoRegister {//...Auto Register
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.deviceNotFound {//...Not Found
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN11, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.frequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.deviceInActive {//...Inactive
                                let errorDict = [Dictkeys.errorkey:Log.getAPIErrorMsg(errorCode:  dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN12, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.frequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.objectMoved {//...Discovery URL
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN13, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.cpidNotFound {//...CPID Not Found
                                let errorDict = [Dictkeys.errorkey:Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN14, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else {
                                let errorDict = [Dictkeys.errorkey:Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)

                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN15, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            }
                            
                        } else {
                            
                            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                            
                        }
                    }
                } else {
                    
                    print("Error parsing DSC: \(String(describing: error))")
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: error!.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                
                    if SDKConstants.developmentSDKYN {
                        self.blockHandlerDeviceCallBack(["sdkStatus": "error"])
                    }
                }
                self.boolCanCallInialiseYN = true
            }
        }
    }
    
    /**
    -start Timer For ReInitialiseDSC
     
    - parameters:
        - durationSyncFrequency: timeInterval as double
      
     - Returns
        returns nothing
     */
    private func startTimerForReInitialiseDSC(durationSyncFrequency: Double) {
        self.repeatTimerCount = 0
        self.timerNotRegister = Timer(timeInterval: durationSyncFrequency, target: self, selector: #selector(self.reInitialise), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timerNotRegister!, forMode: .default)
        self.timerNotRegister!.fire()
    }
    
    @objc private func reInitialise() {
        if self.repeatTimerCount < 5{
            print("reInitialise")
            self.repeatTimerCount += 1
            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN06, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
            initaliseCall(uniqueId: strUniqueId)
        }else{
            if self.timerNotRegister != nil {
                self.timerNotRegister?.invalidate()
                self.timerNotRegister = nil
            }
        }
    }
    
    /**
    -startMQTTCall
     
    - parameters:
        - dataSyncResponse:  data as [String:Any] format
      
     - Returns
        returns nothing
     */
    private func startMQTTCall(dataSyncResponse: [String:Any],password:String = "") {
        if dataSyncResponse["p"] != nil {
            
            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN05, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
//            startEdgeDeviceProcess(dictSyncResponse: dataSyncResponse)
            self.objMQTTClient.initiateMQTT(dictSyncResponse: dataSyncResponse,password: password) { (dataToPass, typeAction) in
                
                print("typeAction \(typeAction) \(dataToPass ?? "")")
                
                //typeAction == 1   //...For Development Call Back
                //typeAction == 2   //...For Device Command Fire
                //typeAction == 3   //...For Updated Sync Response
                //typeAction == 4   //...For Get Desired and Reported twin property
                //typeAction == 5   //...For Get All Twin Property
                //typeAction == 6   //...For Perform Dispose
                //typeAction == 7   //...For Device attribute
                //typeAction == 8   //...For Device twins
                //typeAction == 9   //...For Getting child devices
                //typeAction == 10  //...For Getting Edge rules
                //typeAction == 11  //...For Attribite update
                //typeAction == 12  //...For Device command
                //typeAction == 13  //...For Refresh child device
                //typeAction == 14  //...For Rule change update
                //typeAction == 15  //...For OTA Command
                //typeAction == 16  //...For Module Command
                //typeAction == 17  //...For OnCreate Device
                //typeAction == 18  //...For Delete Device
                //typeAction == 19  //...For Start heart rate
                //typeAction == 20  //...For Stop heart rate
                
                if typeAction == 1 {
                    if let dataMessage = dataToPass as? [String:Any] {
                        if let strMsgStatus = dataMessage["sdkStatus"] as? String {
                            if strMsgStatus == "connect" {
                            } else if strMsgStatus == "error" {
                            } else if strMsgStatus == "success" {
                            }
                        }
                    }
                }
                
                if (typeAction == 1 && SDKConstants.developmentSDKYN) || typeAction == 2 {
                    if dataToPass as? String ?? "" == Log.Errors.ERR_IN14.rawValue{
                        
                    }else{
                        self.blockHandlerDeviceCallBack(dataToPass)
                    }
                   
                } else if typeAction == 3 {
                    self.getUpdatedSyncResponseFor(strKey: dataToPass as! Int)
                } else if typeAction == 4 {
                    var dataTwin: [String:Any] = [:]
                    dataTwin[Dictkeys.desireKey] = dataToPass
                    dataTwin[Dictkeys.uniqueIDKey] = self.strUniqueId
                    self.blockHandlerTwinUpdateCallBack(dataTwin)
                } else if typeAction == 5 {
                    var dataTwin: [String:Any] = dataToPass as! [String : Any]
                    dataTwin[Dictkeys.uniqueIDKey] = self.strUniqueId
                    self.blockHandlerTwinUpdateCallBack(dataTwin)
                } else if typeAction == 6 {
                    self.dispose(sdkconnection: dataToPass as! String)
                }else if typeAction == 7{
                    print("Did recive 201 startMQTTCall")
                    self.startEdgeDeviceProcess(dictSyncResponse: self.dictSyncResponse)
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetAttribuesCallBack(dataToPass)
                }
                else if typeAction == 8{
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetTwinsCallBack(dataToPass)
                }
                else if typeAction == 9{
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetChildDevicesCallback(dataToPass)
                }  else if typeAction == 10{
                    print("Edge rule match \(String(describing: dataToPass))")
                    self.parseEdgeRuleResponse(response: dataToPass as! [String : Any])
                } else if typeAction == 11{
                    print("Attribute update \(String(describing: dataToPass))")
                    self.callBackDelegate?.onAttrChangeCommand(response: dataToPass as? [String : Any] ?? [:])
                }else if typeAction == 12{
                    self.callBackDelegate?.onDeviceCommandCallback(response: dataToPass as? [String : Any] ?? [:], error: nil)
                }else if typeAction == 13{
                    self.callBackDelegate?.onDeviceChangeCommand(response: dataToPass as? [String : Any] ?? [:])
                }else if typeAction == 14{
                    self.objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_EDGE_RULE.rawValue], topic: "")
                    self.callBackDelegate?.onRuleChangeCommand(response: dataToPass as? [String : Any] ?? [:])
                }else if typeAction == 15{
                    self.callBackDelegate?.onOTACommand(response: dataToPass as? [String : Any] ?? [:])
                }
                else if typeAction == 16{
                    self.callBackDelegate?.onModuleCommand(response: dataToPass as? [String : Any] ?? [:])
                } else if typeAction == 17{
                    self.callBackDelegate?.onCreateChildDevice(response: dataToPass as? [String : Any] ?? [:])
                } else if typeAction == 18{
                    self.callBackDelegate?.onDeviceDeleteCommand(response: dataToPass as? [String : Any] ?? [:])
                }else if typeAction == 19{
                    let dict = dataToPass as? [String : Any]
                    let fValue = dict?["f"] as? Int
                    SDKClient.shared.onHeartbeatCommand(isStart: true, df: fValue ?? 0)
                    self.blockHandlerDeviceCallBack(dataToPass)
                }else if typeAction == 20{
                    SDKClient.shared.onHeartbeatCommand(isStart: false)
                    self.blockHandlerDeviceCallBack(dataToPass)
                }
                else if typeAction == 21{
                    let dict = dataToPass as? [String : Any]
                    let dfValue = dict?["df"] as? Int ?? 0
                    SDKClient.shared.onFrequencyChangeCommand(dfValue: dfValue)
                }
            }
        } else {
            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN11, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        }
    }
    
    /**
    - parameters:
        - strkey:  key in string format
      
     - Returns
        returns nothing
     */
    private func getUpdatedSyncResponseFor(strKey: Int) {
        var dict: [String:Any]?
        if strKey == CommandType.PASSWORD_INFO_UPDATE.rawValue {//...PasswordChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.protocolKey: true]]
        } else if strKey == CommandType.DEVICE_INFO_UPDATE.rawValue {//...DeviceChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.device: true]]
        } else if strKey == CommandType.DATA_FREQUENCY_UPDATE.rawValue {//...DataFrequencyUpdated
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.sdkConfig: true]]
        }
        if dict != nil {
            //kirtan
            let bu = dictReference[keyPath:"d.bu"]
            objCommon.makeSyncCall(withBaseURL: bu as! String + "sync", withData: dict) { (data, response, error) in
                if error == nil {
                    let errorParse: Error? = nil
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    if dataDeviceTemp == nil {
                        print("Error parsing Sync Call: \(String(describing: errorParse))")
                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_PS01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: errorParse?.localizedDescription ?? "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                    } else {
                        print("Success Sync Call: \(String(describing: dataDeviceTemp))")
                        
                        let dataDevice = dataDeviceTemp as! [String:Any]
                        
                        if dataDevice["d"] != nil {
                            
                            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                            
                            if dataDevice[keyPath:"d.rc"] as! Int == DeviceSync.Response.ok {
                                var dictToUpdate = self.dictSyncResponse
                                if strKey == CommandType.PASSWORD_INFO_UPDATE.rawValue {
                                    dictToUpdate?[Dictkeys.protocolkey] = dataDevice[keyPath:"d.p"]
                                    if dictToUpdate != nil {
                                        self.startMQTTCall(dataSyncResponse: dictToUpdate!)
                                    } else {
                                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN11, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                                    }
                                } else if strKey == CommandType.DEVICE_INFO_UPDATE.rawValue {
                                    dictToUpdate?[Dictkeys.dKey] = dataDevice[keyPath:"d.d"]
                                } else if strKey == CommandType.DATA_FREQUENCY_UPDATE.rawValue {
                                    dictToUpdate?["sc"] = dataDevice[keyPath:"d.sc"]
                                }
                                if dictToUpdate != nil {
                                    self.dictSyncResponse = dictToUpdate
                                }
                            }
                            
                        } else {
                            
                            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                            
                        }
                    }
                } else {
                    print("Error parsing Sync Call: \(String(describing: error))")
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: error!.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            }
        }
    }
    
    //MARK: - SendData: Logic Methods
    /**
    -set data format to send on MQTT
     
    - parameters:
        - data:  data in [String:Any] format
      
     - Returns
        returns nothing
     */
    func setSendDataFormat(data: [[String:Any]]) {
        let timeNow = objCommon.now()
        let dict = dictSyncResponse!
        for d: [String: Any] in data  {
            autoreleasepool {
                let uniqueIds = dict[Dictkeys.dKey].flatMap{($0 as! [[String:Any]]).map { $0[Dictkeys.idkey] }} as! [String]
                if uniqueIds.contains(d[Dictkeys.uniqueIDKey] as! String) {
                    let dictData = loadDataToSendIoTHub(fromSDKInput: d, withData: dict, withTime: d[Dictkeys.timeKey] as! String)
                    if (dictData[Dictkeys.rptdataKey] as! [String:Any]).count > 0 {
                        var dictRptResult = [String: Any]()
                        dictRptResult[Dictkeys.cpIDkey] = dict["cpId"]
                        dictRptResult[Dictkeys.dtgKey] = dict[Dictkeys.dtgKey]
                        dictRptResult[Dictkeys.tKey] = timeNow
                        dictRptResult[Dictkeys.medsageTypekey] = MessageType.rpt
                        dictRptResult[Dictkeys.dKey] = [dictData[Dictkeys.rptdataKey]]
                        dictRptResult[Dictkeys.sdkKey] = [Dictkeys.languageKey: SDKConstants.language, Dictkeys.versionKey: SDKConstants.version, Dictkeys.envKey: strEnv.rawValue]
                        print("If-dictRptResult)")
                        objMQTTClient.publishTopicOnMQTT(withData: dictRptResult, topic: "")
                    } else {
                        print("Else-dictRptResult")
                    }
                    if (dictData["faultdata"] as! [String:Any]).count > 0 {
                        var dictFaultResult = [String: Any]()
                        dictFaultResult["cpId"] = dict["cpId"]
                        dictFaultResult["dtg"] = dict["dtg"]
                        dictFaultResult["t"] = timeNow
                        dictFaultResult["mt"] = MessageType.flt
                        dictFaultResult["d"] = [dictData["faultdata"]]
                        dictFaultResult["sdk"] = ["l": SDKConstants.language, "v": SDKConstants.version, "e": strEnv.rawValue]
                        print("If-dictFaultResult");
                        objMQTTClient.publishTopicOnMQTT(withData: dictFaultResult, topic: "")
                    } else {
                        print("Else-dictFaultResult")
                    }
                } else {
                    print("UniqueId not exist in 'devices'")
                }
            }
        }
    }
    /**
    load data to send on MQTT
     
    - parameters:
        - dictSDKInput:  data in [String:Any] format
        - dictSaved:
        - timeInput:
      
     - Returns
        returns data in [String: Any] format
     */
    private func loadDataToSendIoTHub(fromSDKInput dictSDKInput: [String: Any], withData dictSaved: [String: Any], withTime timeInput: String) -> [String: Any] {
        var dictDevice = [String : Any]()
        let uniqueIds = dictSaved["d"].flatMap{($0 as! [[String:Any]]).map { $0["id"] }} as! [String]
        if let index = uniqueIds.firstIndex(where: {$0  == dictSDKInput["uniqueId"] as! String}) {
            dictDevice = (dictSaved["d"] as! [[String:Any]])[index]
        }
        
        var dictCommonAttribute: [String : Any]?
        for dictAttribute  in (dictSaved["att"] as! [[String:Any]]) {
            if dictAttribute["p"] as! String == "" {
                dictCommonAttribute = dictAttribute
            }
        }
        
        var dictFaultAttributeData: [String:Any] = [:]
        var dictRptAttributeData: [String:Any] = [:]
        
        for strKey in (dictSDKInput["data"] as! [String:Any]).keys {
            var arrayFltAttrData:[[String:Any]] = []
            var arrayRptAttrData:[[String:Any]] = []
            var dictSelectAttribute: [String:Any]?
            
            for dictAttribute: [String: Any] in (dictSaved["att"] as! [[String: Any]])  {
                //Will Check for if attribute has parent or not with tag validation
                if (dictAttribute["p"] as! String == strKey) && (dictAttribute["tg"] as! String  == dictDevice["tg"] as! String) {
                    dictSelectAttribute = dictAttribute
                }
            }
            
            if dictSelectAttribute != nil {//Attribute has parent
                print("Attribute is parent")
                var arrayFltTmp:[[String:Any]] = []
                var arrayRptTmp:[[String:Any]] = []
                let strkeyPathM = KeyPath("data.\(strKey)")
                for strKeyChild: String in (dictSDKInput[keyPath:strkeyPathM] as! [String:Any]).keys {
                    let strkeyPath = KeyPath("data.\(strKey).\(strKeyChild)")
                    let dictForm = getAttributeForm(with: dictSelectAttribute!, withForKey: strKeyChild, withValue: dictSDKInput[keyPath:strkeyPath]!, withIsParent: false, withTag: "") as [String:Any]
                    if dictForm.count > 0 {
                        if !(dictForm["faultAttribute"] as! Int != 0) {
                            arrayFltTmp.append(dictForm["dataAtt"] as! [String : Any])
                        } else {
                            arrayRptTmp.append(dictForm["dataAtt"] as! [String : Any])
                        }
                    }
                }
                
                if arrayFltTmp.count > 0 {
                    var dictPFlt: [String:Any] = [:]
                    for dicD:[String:Any] in arrayFltTmp {
                        dictPFlt[dicD["key"] as! String] = dicD["value"]
                    }
                    arrayFltAttrData.append(["key": dictSelectAttribute!["p"] as Any, "value": dictPFlt])
                }
                
                if arrayRptTmp.count > 0 {
                    var dictPRpt: [String:Any] = [:]
                    for dicD:[String:Any] in arrayRptTmp {
                        dictPRpt[dicD["key"] as! String] = dicD["value"]
                    }
                    arrayRptAttrData.append(["key": dictSelectAttribute!["p"] as Any, "value": dictPRpt])
                }
                
            } else {//Attribute has no parent
                print("Attribute is not parent")
                if dictCommonAttribute != nil {
                    let strkeyPath = KeyPath("data." + strKey)
                    let dictForm = getAttributeForm(with: dictCommonAttribute!, withForKey: strKey, withValue: dictSDKInput[keyPath:strkeyPath]!, withIsParent: true, withTag: dictDevice["tg"] as! String)
                    if dictForm.count > 0 {
                        if !(dictForm["faultAttribute"] as! Int != 0) {
                            arrayFltAttrData.append(dictForm["dataAtt"] as! [String : Any])
                        } else {
                            arrayRptAttrData.append(dictForm["dataAtt"] as! [String : Any])
                        }
                    }
                } else {
                    print("Common attribute not available")
                }
            }
            
            if arrayFltAttrData.count > 0 {
                for dicD:[String:Any] in arrayFltAttrData {
                    dictFaultAttributeData[dicD["key"] as! String] = dicD["value"]
                }
            }
            if arrayRptAttrData.count > 0 {
                for dicD:[String:Any] in arrayRptAttrData {
                    dictRptAttributeData[dicD["key"] as! String] = dicD["value"]
                }
            }
            
        }
        
        print("dictFaultAttributeData: \(dictFaultAttributeData)")
        print("dictRptAttributeData: \(dictRptAttributeData)")
        
        var dictDataFault = [String: Any]()
        if dictFaultAttributeData.count > 0 {
            dictDataFault["id"] = dictDevice["id"]
            dictDataFault["dt"] = timeInput
            dictDataFault["d"] = [dictFaultAttributeData]
            dictDataFault["tg"] = dictDevice["tg"]
        }
        var dictDataRpt = [String: Any]()
        if dictRptAttributeData.count > 0 {
            dictDataRpt["id"] = dictDevice["id"]
            dictDataRpt["dt"] = timeInput
            dictDataRpt["d"] = [dictRptAttributeData]
            dictDataRpt["tg"] = dictDevice["tg"]
        }
        
        return ["faultdata": dictDataFault, "rptdata": dictDataRpt]
    }
    /**
     getAttributeForm
     
    - parameters:
        - dictAttribute:  data in [String:Any] format
        - strKey:
        - idValue:
        - boolYNParent:
        - strTag:
      
     - Returns
        returns data in [String: Any] format
     */
    private func getAttributeForm(with dictAttribute: [String: Any], withForKey strKey: String, withValue idValue: Any, withIsParent boolYNParent: Bool, withTag strTag: String) -> [String: Any] {
        var dictResultAttribute = [String: Any]()
        for dict: [String: Any] in dictAttribute[Dictkeys.dKey] as! [[String: Any]] {
            if boolYNParent {
                if (dict[Dictkeys.localNameKey] as! String == strKey) && (dict[Dictkeys.tagkey] as! String == strTag) {
                    let dictAttr = [strKey: idValue]
                    let boolYN: Bool = checkForIsValidOrNotWith(forData: dict, withValue: idValue)
                    dictResultAttribute["faultAttribute"] = (boolYN ? 1 : 0)
                    dictResultAttribute["dataAttribute"] = dictAttr
                    dictResultAttribute["dataAtt"] = ["key": strKey, "value": idValue]
                }
            } else {
                if (dict["ln"] as! String == strKey) {
                    let dictAttr = [strKey: idValue]
                    let boolYN: Bool = checkForIsValidOrNotWith(forData: dict, withValue: idValue)
                    dictResultAttribute["faultAttribute"] = (boolYN ? 1 : 0)
                    dictResultAttribute["dataAttribute"] = dictAttr
                    dictResultAttribute["dataAtt"] = ["key": strKey, "value": idValue]
                }
            }
        }
        return dictResultAttribute
    }
    
    private func checkForIsValidOrNotWith(forData dictForData: [String: Any], withValue idValue: Any) -> Bool {
        if dictForData[Dictkeys.datekey] as? Int == DataType.dtNumber {
            let scan = Scanner(string: "\(Int(String(describing: idValue)) ?? 0)")
            var val: Int32 = 0
            if scan.scanInt32(&val) && scan.isAtEnd {
                
            } else {
                return false
            }
        }
        let arr = (dictForData[Dictkeys.dataValidaionKey] as! String).components(separatedBy: ",")
        if arr.count != 0 && !(dictForData[Dictkeys.dataValidaionKey] as! String == "") {
            if dictForData[Dictkeys.datekey] as? Int == DataType.dtNumber {
                let valueToCheck = Int(String(describing: idValue)) ?? 0
                var boolInYN = false
                for strObject: String in arr {
                    if strObject.components(separatedBy: "to").count == 2 {
                        let arrayComponent = strObject.components(separatedBy: "to")

                        let min = Int(arrayComponent[0].trimmingCharacters(in: .whitespaces)) ?? 0
                        let max = Int(arrayComponent[1].trimmingCharacters(in: .whitespaces)) ?? 0

                        if valueToCheck <= max && valueToCheck >= min {
                           // print("if")
                            boolInYN = true
                        }
                    } else {
                        if Int(strObject) ?? 0 == valueToCheck || strObject.count == 0 {
                            boolInYN = true
                        }
                    }
                }
                return boolInYN
            } else if dictForData[Dictkeys.datekey] as? Int == DataType.dtString {
                if arr.contains(idValue as! String) {
                    return true
                }
                return false
            }
        }
        return true
    }
    
    func validateData(data: [String:Any],skipValidation:Bool){
        let arrData = data[Dictkeys.dKey] as? [[String:Any]]
        var dictValidData = [String:Any]()
        var dictInValidData = [String:Any]()
        let boolEdgeDevice = dictSyncResponse[keyPath: "meta.edge"] as? Int
        var dictForEdgeRuleData = [String:Any]()
        
        if arrData?.count ?? 0 > 1{
            print("contains child device")
            var arrDictValidData = [[String:Any]]()
            var arrDictInValidData = [[String:Any]]()
            let arrAtt = IoTConnectManager.sharedInstance.attributes
            print("att \(String(describing: arrAtt?.att?.count))")
            
            for i in 0...(arrData?.count ?? 0)-1{
                if let dictValD = arrData?[i][Dictkeys.dKey] as? [String:Any]{
                    dictValD.forEach({ (dictkey:String,val:Any) in
                        print("key_val gateway \(dictkey) \(val) i\(i)")
                            
                        for j in 0...(arrAtt?.att?.count ?? 0)-1{
                            if let valDict = val as? [String:Any]{
                                for (valDictKey,dictValue) in valDict{
                                    print("valDictKey \(valDictKey) dictValue \(dictValue) dVal \(String(describing: arrAtt?.att?[j].d))")
                                    var arrFilterD = arrAtt?.att?[j].d?.filter({$0.ln == valDictKey})
                                    if arrFilterD?.count ?? 0 > 0{
                                        print("arrFilterD gateway \(String(describing: arrFilterD))")
                                        var isValidData = skipValidation
                                        if !skipValidation{
                                            isValidData = checkisValValid(val: dictValue as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
                                        }
                                        if isValidData{
                                            if boolEdgeDevice == 1, let _ = Double(dictValue as? String ?? ""){
                                                arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictkey:[valDictKey:dictValue]],id: arrData?[0][Dictkeys.idkey] as? String ?? "",tg: arrData?[0][Dictkeys.tagkey] as? String ?? "",dt: arrData?[0][Dictkeys.datekey] as? String ?? "" )
                                                
                                                if edgeRules != nil,!(dictValue as? String ?? "").isEmpty{
                                                    createResponseForEdgeRuleDeviceTelemetryData(dict: [dictkey:[valDictKey:dictValue]])
                                                }
                                            }
                                            if arrDictValidData.count == 0{
                                                arrDictValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:[valDictKey:dictValue]]]
                                                )
                                                
                                            }else{
                                                if let index = arrDictValidData.firstIndex(where: {$0[Dictkeys.idkey] as? String  == arrData?[i][Dictkeys.idkey] as? String}) {
                                                    var dVal = arrDictValidData[index][Dictkeys.dKey] as? [String:Any]
                                                    let attDict = dVal?[dictkey] as? [String:Any]
                                                    print("attDict \(String(describing: attDict))")
                                                    let newDict = [valDictKey:dictValue]
                                                    if attDict == nil{
                                                        dVal?.append(anotherDict: [dictkey:[valDictKey:dictValue]])
                                                    }else{
                                                        dVal?[dictkey] = attDict?.merging(newDict , uniquingKeysWith: { current, _ in
                                                            return current
                                                        })
                                                    }
                                                    arrDictValidData[index][Dictkeys.dKey]  = dVal
                                                    print("arrDictValidData \(arrDictValidData)")
                                                }else{
                                                    arrDictValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:[valDictKey:dictValue]]]
                                                    )
                                                    print("arrDictValidData \(arrDictValidData)")
                                                }
                                            }
                                        }else{
//                                            dict = dictInValidData
                                            if arrDictInValidData.count == 0{
                                                arrDictInValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:[valDictKey:dictValue]]]
                                                                          
                                                )
                                                print("arrDictInValidData \(arrDictInValidData)")
                                            }else{
                                                if let index = arrDictInValidData.firstIndex(where: {$0[Dictkeys.idkey] as? String  == arrData?[i][Dictkeys.idkey] as? String}) {
                                                    var dVal = arrDictInValidData[index][Dictkeys.dKey] as? [String:Any]
                                                    let attDict = dVal?[dictkey] as? [String:Any]
                                                    
                                                    let newDict = [valDictKey:dictValue]
                                                    if attDict == nil{
                                                        dVal?.append(anotherDict: [dictkey:[valDictKey:dictValue]])
                                                    }else{
                                                        dVal?[dictkey] = attDict?.merging(newDict , uniquingKeysWith: { current, _ in
                                                            return current
                                                        })
                                                    }
                                                   
                                                    arrDictInValidData[index][Dictkeys.dKey]  = dVal
                                                    print("arrDictInValidData \(arrDictInValidData)")
                                                    
                                                }else{
                                                    arrDictInValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:[valDictKey:dictValue]]]
                                                    )
                                                    print("arrDictInValidData \(arrDictInValidData)")
                                                }
                                            }
                                        }
                                        arrFilterD?.removeAll()
                                    }
                                }
                            }else{
                                let arrFilterD = arrAtt?.att?[j].d?.filter({$0.ln == dictkey})
                                if arrFilterD?.count ?? 0 > 0{
    //                                print("arrFilterD \(arrFilterD)")
//                                    isDataFound = true
                                    var isValidData = skipValidation
                                    
                                    if !skipValidation{
                                        isValidData = checkisValValid(val: val as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
                                    }
                                    if isValidData{
//                                        dictValidData.append(anotherDict: [dictkey:val])
                                        
                                        if boolEdgeDevice == 1, let _ = Double(val as? String ?? ""){
                                            arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictkey:val],id: arrData?[i][Dictkeys.idkey] as? String,tg: arrData?[i][Dictkeys.tagkey] as? String,dt: arrData?[0][Dictkeys.datekey] as? String ?? "")
                                            
                                            if edgeRules != nil,!(val as? String ?? "").isEmpty{
                                                createResponseForEdgeRuleDeviceTelemetryData(dict:[dictkey:val])
                                            }
                                            
                                        }
                                        //issue same id key
                                        if let index = arrDictValidData.firstIndex(where: {$0[Dictkeys.idkey] as? String  == arrData?[i][Dictkeys.idkey] as? String}) {
                                            var dVal = arrDictValidData[index][Dictkeys.dKey] as? [String:Any]
                                            let newDict = [dictkey:val]
                                            dVal = dVal?.merging(newDict , uniquingKeysWith: { current, _ in
                                                return current
                                            })
                                            arrDictValidData[index][Dictkeys.dKey]  = dVal
                                        }else{
                                            arrDictValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:val]]
                                                                    
                                            )
                                        }
                                        print("arrDictValidData gateway \(arrDictValidData)")
                                    }else{
                                        if let index = arrDictInValidData.firstIndex(where: {$0[Dictkeys.tagkey] as? String  == arrData?[i][Dictkeys.tagkey] as? String}) {
                                            var dVal = arrDictInValidData[index][Dictkeys.dKey] as? [String:Any]

                                            let newDict = [dictkey:val]
                                            dVal = dVal?.merging(newDict , uniquingKeysWith: { current, _ in
                                                return current
                                            })
                                            arrDictInValidData[index][Dictkeys.dKey]  = dVal
                                        }else{
                                            arrDictInValidData.append([Dictkeys.datekey:arrData?[i][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[i][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[i][Dictkeys.tagkey] ?? "",Dictkeys.dKey:[dictkey:val]])
                                        }
                                        print("arrDictInValidData gateway \(arrDictInValidData)")
                                    }
//                                    break
                                }
                            }
                        }
                    })
                }
            }
            
            if !arrDictValidData.isEmpty{
                dictValidData = [Dictkeys.datekey:data[Dictkeys.datekey
                                                      ] ?? "",Dictkeys.dKey:arrDictValidData]
                
                if boolEdgeDevice == 1{
                    print("dictValidData edgeDevice \(dictValidData)")
                    sendMessageForEdgeRuleMatch(dictValidData: dictValidData, dictDeviceTelemetry: dictForEdgeRuleData,id: arrData?[0][Dictkeys.idkey] as? String ?? "", tag: arrData?[0][Dictkeys.tagkey] as? String ?? "")
                }else{
                    let topic = dictSyncResponse[keyPath:"p.topics.rpt"] as! String
                    prevSendDataTime = Date()
                    objMQTTClient.publishTopicOnMQTT(withData: dictValidData, topic: topic)
                }
               
                print("final dictValidData gateway \(dictValidData)")
            }
            
            if !arrDictInValidData.isEmpty{
                dictInValidData = [Dictkeys.datekey:data[Dictkeys.datekey] ?? "",Dictkeys.dKey:arrDictInValidData]
                
                if boolEdgeDevice == 1{
                    
                }else{
                    let topic = dictSyncResponse[keyPath:"p.topics.flt"] as! String
                    prevSendDataTime = Date()
                    objMQTTClient.publishTopicOnMQTT(withData: dictInValidData, topic: topic)
                    print("final dictInValidData gateway \(dictInValidData)")
                }
            }
        }else{
            print("count is 1")
            let dictValD = arrData?[0][Dictkeys.dKey] as? [String:Any]

            dictValD?.forEach {
                print("key_val \($0.key) \($0.value)")
                let dictValDKey = $0.key
                let value = $0.value
                let arrAtt = IoTConnectManager.sharedInstance.attributes
                print("att \(String(describing: arrAtt?.att?.count))")
                 
                for i in 0...(arrAtt?.att?.count ?? 0)-1{
                    print("arrAtt?.att \(i)")
                        if let valDict = value as? [String:Any]{
                            for (valDictKey,dictValue) in valDict{
                                var arrFilterD = arrAtt?.att?[i].d?.filter({$0.ln == valDictKey})
                                if arrFilterD?.count ?? 0 > 0{
                                    print("arrFilterD \(String(describing: arrFilterD))")
                                    var dict = [String:Any]()
                                    var isValidData = skipValidation
                                    if !skipValidation{
                                        isValidData = checkisValValid(val: dictValue as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
                                    }
                                  
                                    if isValidData{
                                        dict = dictValidData
                                    }else{
                                        dict = dictInValidData
                                    }
                                    
                                    if dict[$0.key] != nil{
                                        let val = dict[$0.key] as? [String:Any]
                                        let newVal = [valDictKey:dictValue] as? [String:Any]
                                        dict[$0.key] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                                            return current
                                        })
                                        print("dictValidData \(valDictKey) \(dictValidData)")
                                    }else{
                                        dict.updateValue([valDictKey:dictValue], forKey:$0.key)
                                    }
                                    arrFilterD?.removeAll()
                                    if isValidData{
                                       dictValidData = dict

                                        if boolEdgeDevice == 1, let _ = Double(dictValue as? String ?? ""){
                                            arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictValDKey:[valDictKey:dictValue]],id: arrData?[0][Dictkeys.idkey] as? String ?? "",tg: arrData?[0][Dictkeys.tagkey] as? String ?? "",dt: arrData?[0][Dictkeys.datekey] as? String ?? "" )
                                            
                                            if edgeRules != nil,!(dictValue as? String ?? "").isEmpty{
                                                createResponseForEdgeRuleDeviceTelemetryData(dict: [dictValDKey:[valDictKey:dictValue]])
                                            }
                                        }
                                    }else{
                                        dictInValidData = dict
                                    }
                                    print("dictValidData \(valDictKey) \(dictValidData)")
                                    print("dictInValidData \(valDictKey) \(dictInValidData)")
                                }
                            }
                        }else{
                            let arrFilterD = arrAtt?.att?[i].d?.filter({$0.ln == dictValDKey})
                            if arrFilterD?.count ?? 0 > 0{
                                var isValidData = skipValidation
                                if !skipValidation{
                                    isValidData = checkisValValid(val: value as? String ?? "", dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
                                }
                               
                                if isValidData{
                                    dictValidData.append(anotherDict: [$0.key:$0.value])
                                    print("dictValidData \(dictValidData)")

                                    if boolEdgeDevice == 1, let _ = Double(value as? String ?? ""){
                                        arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictValDKey:value],id: arrData?[0][Dictkeys.idkey] as? String ?? "",tg: arrData?[0][Dictkeys.tagkey] as? String ?? "",dt: arrData?[0][Dictkeys.datekey] as? String ?? "")
                                        
                                        if edgeRules != nil{
                                            createResponseForEdgeRuleDeviceTelemetryData(dict: [dictValDKey:value])
                                        }
                                    }
                                }else{
                                    dictInValidData.append(anotherDict: [$0.key:$0.value])
                                    print("dictInValidData \(dictInValidData)")
                                }
                                break
                            }
                        }
                }
            }
            
            if !dictValidData.isEmpty{
                if boolEdgeDevice != 1{
                    dictValidData = [Dictkeys.datekey:data[Dictkeys.datekey] ?? "",Dictkeys.dKey:[[Dictkeys.datekey:arrData?[0][Dictkeys.datekey] ?? "",Dictkeys.idkey:arrData?[0][Dictkeys.idkey] ?? "",Dictkeys.tagkey:arrData?[0][Dictkeys.tagkey] ?? "",Dictkeys.dKey:dictValidData]]]
                    prevSendDataTime = Date()
                    let topic = dictSyncResponse[keyPath:"p.topics.rpt"] as! String
                    objMQTTClient.publishTopicOnMQTT(withData: dictValidData, topic: topic)
                }else{
                    print("dictValidData edgeDevice \(dictValidData)")
                    sendMessageForEdgeRuleMatch(dictValidData: dictValidData, dictDeviceTelemetry: dictForEdgeRuleData,id: arrData?[0][Dictkeys.idkey] as? String ?? "", tag: arrData?[0][Dictkeys.tagkey] as? String ?? "")
                }
            }
            
            if !dictInValidData.isEmpty{
                dictInValidData = [Dictkeys.datekey:data[Dictkeys.datekey] ?? "",
                                   Dictkeys.dKey:[[Dictkeys.datekey:arrData?[0][Dictkeys.datekey],
                                                   Dictkeys.idkey:arrData?[0][Dictkeys.idkey],
                                                   Dictkeys.tagkey:arrData?[0][Dictkeys.tagkey],
                                                   Dictkeys.dKey:dictInValidData]]]
                
                if boolEdgeDevice != 1{
                    prevSendDataTime = Date()
                    let topic = dictSyncResponse[keyPath:"p.topics.flt"] as! String
                    objMQTTClient.publishTopicOnMQTT(withData: dictInValidData, topic: topic)
                }
            }
        }
        
        func checkisValValid(val:String,dt:Int,dv:String?)-> Bool{
            switch dt{
            case SupportedDataType.intValue:
                if Int32(val) != nil{
                    if validateNumber(value: val, dv: dv, dataType: SupportedDataType.intValue) == true{
                        return true
                    }else{
                        return false
                    }
                }else{
                    if val.isEmpty && (dv == nil || dv?.isEmpty == true){
                        return true
                    }
                    if !val.isEmpty{
                        if let doubleVal = Double(val){
                            let roundVal = Int32(round(doubleVal))
                            if validateNumber(value: "\(roundVal)", dv: dv, dataType: SupportedDataType.intValue) == true{
                                return true
                            }else{
                                return false
                            }
                        }
                    }
                    return false
                }
                
            case SupportedDataType.boolValue:
                let isValid = self.validateBoolValue(value: val, dv: dv)
                if isValid{
                    return true
                }else{
                    return false
                }
            case SupportedDataType.strVal:
                //remaining
                let isValid = self.validateNumber(value: val, dv: dv, dataType: SupportedDataType.decimalVal)
                if isValid{
                    return true
                }else{
                    return false
                }
            case SupportedDataType.bitValue:
                let isValid = self.validateBit(value: val, dv: dv)
                
                if isValid{
                    return true
                }else{
                    return false
                }
                
            case SupportedDataType.dateValue:
                let isValid = validateDate(value: val, dateFormat: "YYYY-MM-dd", dv: dv)
                
                if (isValid){
                    return true
                }else{
                    return false
                }
                
            case SupportedDataType.dateTimeVal:
                let isValid = validateDate(value: val, dateFormat:"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" , dv: dv)
                if isValid{
                    return true
                }else{
                    return false
                }
                
            case SupportedDataType.decimalVal:
                if let floatVal = Float(val){
                    //range is -7.9*1028
                    if floatVal.isLessThanOrEqualTo(8121.2) &&
                        floatVal >= -8121.2
                    {
                        if validateNumber(value: val, dv: dv, dataType: SupportedDataType.decimalVal) == true{
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
                if val.isEmpty && (dv == nil || dv?.isEmpty == true){
                    return true
                }
                return false
                
            case SupportedDataType.latLongVal:
                //[10,8] [11,8]
                if validateLatLong(value: val,dv: dv){
                    return true
                }
                
                return false
                
            case SupportedDataType.longVal:
                if Int64(val) != nil{
                    if validateNumber(value: val, dv: dv, dataType: SupportedDataType.longVal) == true{
                        return true
                    }else{
                        return false
                    }
                }else{
                    if val.isEmpty && (dv == nil || dv?.isEmpty == true){
                        return true
                    }
                    if !val.isEmpty{
                        if let doubleVal = Double(val){
                            let roundVal = Int64(round(doubleVal))
                            if validateNumber(value: "\(roundVal)", dv: dv, dataType: SupportedDataType.intValue) == true{
                                return true
                            }else{
                                return false
                            }
                        }
                    }
                    return false
                }
                
            case SupportedDataType.timeVal:
                if dv == nil || dv?.isEmpty == true{
                    if val.isEmpty == true{
                        return true
                    }
                }
                let arrVal = val.components(separatedBy: ":")
                if arrVal.count >= 3{
                    let isValid = validateDate(value: val, dateFormat: "HH:mm:ss", dv: dv)
                    
                    if isValid{
                        return true
                    }else{
                        return false
                    }
                }else
                {
                    return false
                }
                
            default:
                return false
            }
        }
        
        func createResponseForEdgeRuleDeviceTelemetryData(dict:[String:Any]){
            dict.forEach({ (dictkey:String,dictVal:Any) in
                if let valDict = dictVal as? [String:Any]{
                        if dictForEdgeRuleData[dictkey] != nil{
                            var dict = dictForEdgeRuleData[dictkey] as? [String:Any]
                            dict?.append(anotherDict:valDict)
                            dictForEdgeRuleData[dictkey] = dict
                        }else{
                            dictForEdgeRuleData.append(anotherDict: dict)
                        }
                }else{
                    dictForEdgeRuleData.append(anotherDict: [dictkey:dictVal])
                }
            })
            print("dictForEdgeRuleData \(dictForEdgeRuleData)")
        }
    }
    
    func sendMessageForEdgeRuleMatch(dictValidData:[String:Any],dictDeviceTelemetry:[String:Any],id:String,tag:String){
        if let ruleData = edgeRules{
            if let rule = ruleData.d?.r?[0].con{
                var arrRules = rule.components(separatedBy: " ")//rule.components(separatedBy: "AMD")
                arrRules.removeAll(where: {$0 == "AND"})
                
                if arrRules.count > 0{
                    var arrValidRule = [String:Any]()
                    var arrRulesCopy = arrRules
                    
                    while(arrRulesCopy.count != 0){
                        let ruleArr = Array(arrRulesCopy.prefix(3))
                        let att = ruleArr[0].components(separatedBy: ".")
                        print("Rule seperated \(att)")
                        if att.count == 1{
                            if att[0].contains("#"){
                                print("\(att[0]) contains #")
                                handleHashSeperatedAtt(ruleArr: ruleArr)
                            }else if let val  = dictValidData[att[0]] as? String, !val.isEmpty{
                                let isRuleMatch = checkEdgeRuleVal(valToCompare: Float(val) ?? 0.0, strOperator:ruleArr[1], valToCompareWith: Float(ruleArr[2]) ?? 0.0)
                                print("isRuleMatch \(isRuleMatch) \(ruleArr[0]) \(val)")
//                                dictData.append(anotherDict: [att[0]:val])
                                if isRuleMatch{
                                    arrValidRule.append(anotherDict: [att[0]:val])
                                }
                            }
                        }else{
                            handleHashSeperatedAtt(ruleArr: ruleArr)
                        }
                        arrRulesCopy.removeFirst(3)
                    }
                    print("arrValidrule \(arrValidRule) dataDeviceTelemetry \(dictDeviceTelemetry)")
                    
                    if !arrValidRule.isEmpty{
                        let dictToSend = [Dictkeys.datekey:objCommon.now(),
                                          Dictkeys.dKey:[[Dictkeys.ruleGUIDKey: edgeRules?.d?.r?[0].g ?? "",
                                                          Dictkeys.commandTypeKey:edgeRules?.d?.r?[0].con ?? "",
                                                          Dictkeys.conditionValueKey: arrValidRule,
                                                          Dictkeys.subscriptionGUIDKey: edgeRules?.d?.r?[0].es ?? "",
                                                          Dictkeys.dKey:[dictDeviceTelemetry],
                                                          Dictkeys.idkey: id,
                                                          Dictkeys.datekey:objCommon.now(),
                                                          Dictkeys.tagkey:tag
                                               ]]
                        ] as [String : Any]
                        let topic = dictSyncResponse[keyPath:"p.topics.erm"] as! String
                        objMQTTClient.publishTopicOnMQTT(withData: dictToSend, topic: topic)
                    }

                    func handleHashSeperatedAtt(ruleArr:[String]){
//                        var arrValidRule = [String:Any]()
                        let att = ruleArr[0].components(separatedBy: ".")
                        let arrHashSeperated = att[0].components(separatedBy: "#")
                        print("hashSeperated \(arrHashSeperated)")
                        if arrHashSeperated.count == 1{
                            if let dict  = dictValidData[att[0]] as? [String:Any]{
                                if let val = dict[att[1]] as? String,!val.isEmpty{
                                    let isRuleMatch = checkEdgeRuleVal(valToCompare: Float(val) ?? 0.0, strOperator:ruleArr[1], valToCompareWith: Float(ruleArr[2]) ?? 0.0)
                                    print("isRuleMatch \(isRuleMatch) \(ruleArr[0]) \(val)")
                                    if isRuleMatch{
                                        arrValidRule = addValInNestedDict(dict: arrValidRule, parentName: att[0], attName: att[1], val: val)
                                    }
                                }
                            }
                        }else{
                            var val = ""
                            var attName = ""
                            let arrDictD = dictValidData[Dictkeys.dKey] as? [[String:Any]]
                            
                            if let firstIndexP = arrDictD?.firstIndex(where: {$0[Dictkeys.tagkey] as! String == arrHashSeperated[0]}){
                                print("hashSeerated filter \(arrDictD?[firstIndexP] ?? [:])")
                                var dict = arrDictD?[firstIndexP] as? [String:Any]
                                dict = dict?[Dictkeys.dKey] as? [String:Any]
                                if let dictVal = dict?[arrHashSeperated[1]] as? [String:Any]{
                                    dict = dictVal
                                }
                                
                                if att.count == 1{
                                    val =  dict?[arrHashSeperated[1]] as? String ?? ""
                                    attName = arrHashSeperated[1]
                                }else{
                                    val =  dict?[att[1]] as? String ?? ""
                                    attName = att[1]
                                }
                               
                                if !val.isEmpty{
                                    let isRuleMatch = checkEdgeRuleVal(valToCompare: Float(val) ?? 0.0, strOperator:ruleArr[1], valToCompareWith: Float(ruleArr[2]) ?? 0.0)
                                    print("isRuleMatch \(isRuleMatch) \(ruleArr[0]) \(val)")
                                    
                                    if isRuleMatch{
                                        if att.count == 1{
                                            arrValidRule = [attName:val]
                                        }else{
                                            arrValidRule = addValInNestedDict(dict: arrValidRule, parentName: arrHashSeperated[1], attName: attName, val: val)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkEdgeRuleVal(valToCompare:Float,strOperator:String,valToCompareWith:Float)-> Bool{
        switch strOperator{
        case ">":
             return valToCompare > valToCompareWith
        case "<":
             return valToCompare < valToCompareWith
        case "=":
             return valToCompare == valToCompareWith
        case "!=":
             return valToCompare != valToCompareWith
        case ">=":
             return valToCompare >= valToCompareWith
        case "<=":
             return valToCompare <= valToCompareWith
        default:
            return false
        }
    }
    
    func addValInNestedDict(dict:[String:Any],parentName:String,attName:String,val:String) -> [String:Any]{
        var dictToReturn = [String:Any]()
        dictToReturn = dict
        
        if let objDict = dict[parentName] as? [String:Any]{
            var objDictCopy = objDict
            objDictCopy.append(anotherDict: [attName:val])
            dictToReturn[parentName] = objDictCopy
            return dictToReturn
        }else{
            dictToReturn[parentName] = [attName:val]
        }
        return dictToReturn
    }
    
    func validateDate(value:String,dateFormat:String,dv:String?)->Bool{
        if value.isEmpty == true && (dv == nil || dv?.isEmpty == true){
            return true
        }
        if let validDate = isDateValid(dateVal: value, dateFormat: dateFormat){
            if dv == nil || dv?.isEmpty == true{
                    return true
            }else{
                var newDateArr = dv?.components(separatedBy: ",")
                let arrToData = newDateArr?.filter({$0.contains("to")})
                newDateArr?.removeAll(where: {$0.contains("to")})
                
                if newDateArr?.contains(value) == true{
                    return true
                }
                
                if arrToData?.count  ?? 0 > 0{
                    for i in 0...(arrToData?.count ?? 0)-1{
                        let toArr = arrToData?[i].components(separatedBy: "to")

                        if let startDate = isDateValid(dateVal: toArr?[0].trimmingCharacters(in: .whitespaces) ?? "", dateFormat: dateFormat),let  endDate =  isDateValid(dateVal: toArr?[1].trimmingCharacters(in: .whitespaces) ?? "", dateFormat: dateFormat){
                            let dateRange = startDate...endDate
                            if dateRange.contains(validDate)
                            {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    func isDateValid(dateVal:String,dateFormat:String)->Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = dateFormatter.date(from:dateVal){
            return date
        }else{
            return nil
        }
    }
    
    func validateBit(value:String,dv:String?)->Bool{
        if (dv == nil || (dv?.isEmpty) == true) {
            if value.isEmpty == true{
                return true
            }
            if (value == "0" || value == "1"){
                return true
            }else{
                return false
            }
        }else{
            if (value == dv){
                return true
            }else{
                return false
            }
        }
    }
    
    func validateBoolValue(value:String,dv:String?)->Bool{
        if dv != nil && dv?.isEmpty == false{
                if value == dv{
                    return true
                }else{
                    return false
                }
        }
            if value == "True" ||
                value == "False" ||
                value == "true" ||
                value == "false"{
                return true
            }
        
        if dv == nil || dv?.isEmpty == true{
            if value.isEmpty == true{
                return true
            }
        }
        
        return false
    }
    
    func validateNumber(value:String,dv:String?,dataType:Int)->Bool{
        if dv == nil || dv?.isEmpty == true{
//            if value.isEmpty{
                return true
//            }
        }else{
            var dvInComma = dv?.components(separatedBy: ",")
            let arrToData = dvInComma?.filter({$0.contains("to")})
            dvInComma?.removeAll(where: {$0.contains("to")})

            if dvInComma?.contains(value) == true{
                return true
            }
            
            if arrToData?.count ?? 0 > 0{
                for i in 0...(arrToData?.count ?? 0)-1{
                    let toArr = arrToData?[i].components(separatedBy: "to")
                    if dataType == SupportedDataType.decimalVal{
                        var arrFloat = [Float]()
                        for item in toArr! {
                            arrFloat.append((item.trimmingCharacters(in: .whitespaces) as NSString).floatValue)
                        }
                        
                        if let val = Float(value){
                            if checkValInRange(arrRange: arrFloat, value: val) == true{
                                return true
                            }
                        }
                       
                        
                        if dv == value{
                            return true
                        }
                        
                        return false
                    }else if dataType == SupportedDataType.intValue{
                        let arrInt32 = toArr?.compactMap { Int32($0.trimmingCharacters(in: .whitespaces)) }
                        
                        if let val = Int32(value){
                            if checkValInRange(arrRange: arrInt32 ?? [], value: val) == true{
                                return true
                            }
                        }
                        
                        if dv == value{
                            return true
                        }
                        
                        return false
                    }else if dataType == SupportedDataType.longVal{
                        let arrInt64 = toArr?.compactMap { Int64($0.trimmingCharacters(in: .whitespaces)) }
                        
                        if let val = Int64(value){
                            if checkValInRange(arrRange: arrInt64 ?? [], value: val) == true{
                                return true
                            }
                        }
                        
                        if dv == value{
                            return true
                        }
                        
                        return false
                    }
                }
            }
        }
        return false
    }
    
    func validateLatLong(value:String,dv:String?)->Bool{
        if dv == nil || dv?.isEmpty == true{
            if value.isEmpty{
                return true
            }
        }
        let regex = NSRegularExpression("\\[\\d*\\.?\\d*\\,\\d*\\.?\\d*\\]")
        return regex.matches(value)
    }
    
    func checkValInRange<T:Comparable>(arrRange:[T],value:T)->Bool{
        if arrRange.count > 0{
            let range = arrRange[0]...arrRange[1]
            if range.contains(value){
                return true
            }
        }
        return false
    }
    //MARK: - Method - Reachability Methods
    /**
        check internet available or not
            
        - Returns
                returns boll value for available or not
     */
    func checkInternetAvailable() -> Bool {
        let networkStatus = try! Reachability().connection
        
        switch networkStatus {
//        case nil:
//            return false
        case .cellular:
            return true
        case .wifi:
            return true
        case .none, .unavailable:
            return false
        }
    }
    
    /*
     observer for whenver rechability changed
     */
    func reachabilityObserver() {
        self.reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try reachability?.startNotifier()
        } catch( _) {
        }
    }
    
    /*
     observer function will be called whenever reachability changed
     */
    @objc private func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        var boolInternetAvailable: Bool = false
        switch reachability.connection {
        
        case .cellular:
            boolInternetAvailable = true
            print("Network available via Cellular Data.")
            break
        case .wifi:
            boolInternetAvailable = true
            print("Network available via WiFi.")
            break
        case .none:
            print("Network is not available.")
            break
        case .unavailable:
            print("Network unavailable.")
//            objMQTTClient.disconnect()
        }
        var boolCanReconnectYN = false
        if boolInternetAvailable && !objMQTTClient.boolIsInternetAvailableYN {
            boolCanReconnectYN = true
        }
        objMQTTClient.boolIsInternetAvailableYN = boolInternetAvailable
        if boolCanReconnectYN {
            objMQTTClient.connectMQTTAgain()
        }
    }
    
    //MARK: - Method - Custom Methods
    /*
     startEdgeDeviceProcess
     
     - Parameters
        - dictSyncResponse: date as [String:Any] format
     
     - Returns
        returns nothing
     */
    private func startEdgeDeviceProcess(dictSyncResponse: [String:Any]) {
        let boolEdgeDevice = dictSyncResponse[keyPath: "meta.edge"] as? Int
        if boolEdgeDevice == 1 {
            if let attributes = IoTConnectManager.sharedInstance.attributes{
                IoTConnectManager.sharedInstance.attributes?.connectedTime = Date()
                if let att = attributes.att{
                    for i in 0...att.count-1{
                        for j in 0...(att[i].d?.count ?? 0)-1{
                            if let d = att[i].d?[j]{
                                arrAttData.append(d)
                                var tw = d.tw ?? ""
                                let twUnit = String(tw.removeLast())
                                var timeInterval = tw.toDouble()
                                
                                if twUnit == "h"{
                                    timeInterval = (tw.toDouble() ?? 0.0) * 3600
                                }else if twUnit == "m"{
                                    timeInterval = (tw.toDouble() ?? 0.0) * 60
                                }
                                tw = String(tw.dropLast())
                                
                                let parentName = att[i].p
                                
                                if parentName?.isEmpty == true ||
                                    parentName == nil{
                                    timerEdgeDevice.append( Timer.scheduledTimer(timeInterval: timeInterval ?? 0.0, target: self, selector: #selector(fireTimerForEdgeDevice), userInfo: d, repeats: true))
                                }else{
                                    var attD = d
                                    attD.p = parentName ?? ""
                                    timerEdgeDevice.append( Timer.scheduledTimer(timeInterval: timeInterval ?? 0.0, target: self, selector: #selector(fireTimerForEdgeDevice), userInfo: attD, repeats: true))
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func fireTimerForEdgeDevice(timer:Timer){
        print("timer userInfo \(timer.userInfo ?? "")")
        if let userInfo = timer.userInfo as? AttData{
            let ln = (userInfo.p == nil ? userInfo.ln ?? "" : userInfo.p)!//userInfo.ln ?? ""

            if !arrCalcDictEdgeDevice.isEmpty{
                for i in 0...arrCalcDictEdgeDevice.count-1{
                    print("fire timer \(i)")
                    var dictD = arrCalcDictEdgeDevice[i][Dictkeys.dKey] as? [String:Any]
                    if let valDict = dictD?[ln]{
                        print("Dict found")
                        let dataToSend = [
                            Dictkeys.datekey:arrCalcDictEdgeDevice[i][Dictkeys.datekey] ?? "",
                            Dictkeys.dKey:[
                                [
                                    Dictkeys.idkey:arrCalcDictEdgeDevice[i][Dictkeys.idkey] ?? "",
                                    Dictkeys.tagkey:arrCalcDictEdgeDevice[i][Dictkeys.tagkey] ?? "",
                                    Dictkeys.datekey:arrCalcDictEdgeDevice[i][Dictkeys.datekey] ?? "",
                                    Dictkeys.dKey:[
                                        "\(ln )":valDict
                                    ]
                                ]]] as [String : Any]
                        let topic = dictSyncResponse[keyPath:"p.topics.erpt"] as! String
                        objMQTTClient.publishTopicOnMQTT(withData: dataToSend, topic: topic)
                        dictD?.removeValue(forKey: "\(ln )")
                        arrCalcDictEdgeDevice[i][Dictkeys.dKey] = dictD
                                               print("arrCalcDictEdgeDevice \(arrCalcDictEdgeDevice)")
                        if let firstIndexData = arrDataEdgeDevices.firstIndex(where: {$0[ln] != nil}){
                            arrDataEdgeDevices.remove(at: firstIndexData)
                            print("arrDataEdgeDevices \(arrDataEdgeDevices)")
                        }
                        break
                    }
                }
            }else{
                print("arrCalcDictEdgeDevice is empty")
            }
        }else{
            print("userinfo is not decoded")
        }
    }
    
    func parseEdgeRuleResponse(response:[String:Any]){
        if let dataEdgeRule = try? JSONSerialization.data(withJSONObject: response){
            if let jsonData = try? JSONDecoder().decode(ModelEdgeRule.self, from: dataEdgeRule) {
               print("Edge rule parsed Data \(jsonData)")
                self.edgeRules = jsonData
            } else {
                print("Error parsing EdgeRule Response")
            }
        }
    }
    
    func startHeartRate(df:Double){
//        if timerHeartRate == nil{
        timerHeartRate = Timer.scheduledTimer(withTimeInterval: df, repeats: true, block: { timer in
            print(Date())
            let topic = self.dictSyncResponse[keyPath:"p.topics.hb"] as! String
            self.objMQTTClient.publishTopicOnMQTT(withData: [:], topic: topic)
        })
//        }else{
//            timerHeartRate = nil
//            timerHeartRate = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { timer in
//                let topic = self.dictSyncResponse[keyPath:"p.topics.hb"] as! String
//                self.objMQTTClient.publishTopicOnMQTT(withData: [:], topic: topic)
//            })
//        }
       
    }
    
    func stopHeartRate(){
        //        if timerHeartRate != nil{
        timerHeartRate.invalidate()
//        timerHeartRate = nil
        //        }
    }
    
    func generateSasToken(resourceUri: String, key: String) throws -> String {
        // Token will expire in one year
        let expiry = Int(Date().timeIntervalSince1970) + 31536000
        
        let encodedURL = resourceUri.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        print("Encoded URL \(encodedURL ?? "")")
        
        let stringToSign = "\(encodedURL ?? "")\n\(expiry)"//(encodedURL ?? "") + "\(expiry)"
        print("stringToSign \(stringToSign)")
        
        let decodedKey = Data(base64Encoded: key)!
        
        var hmacContext = CCHmacContext()
        CCHmacInit(&hmacContext, CCHmacAlgorithm(kCCHmacAlgSHA256), (decodedKey as NSData).bytes, decodedKey.count)
        CCHmacUpdate(&hmacContext, stringToSign, stringToSign.count )
        
        var macOut = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmacFinal(&hmacContext, &macOut)
        
        let signature = Data(macOut).base64EncodedString(options: [])
        let encodedSignature = signature.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    print("encodedSignature \(encodedSignature)")

        let token = "SharedAccessSignature sr=" +  "\(encodedURL ?? "")" + "&sig=" + "\(encodedSignature ?? "")" + "&se=" + String(expiry)
        
        return token
    }
}
