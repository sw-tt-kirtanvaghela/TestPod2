//
//  MqttClientService.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/27/21.
//

import Foundation
import CocoaMQTT

class MqttClientService {
    static let shared = MqttClientService()
    var cocoaMqtt: CocoaMQTT?
    var mqttConfigObj: CocoaMqttConfig?
    
    var connctionCompletion: ((Bool) -> Void)?
    var publishedSuccess: ((Bool) -> Void)?
    var subscribedSuccess: ((Bool) -> Void)?
    var unsubscribedSuccess: ((Bool) -> Void)?
    var disconnectedSuccess: ((Bool) -> Void)?
    
    func setupMqtt(mqttConfig: CocoaMqttConfig, iotData: IoTData) {
        mqttConfigObj = mqttConfig
        let cocoaMqtt = CocoaMQTT(clientID: iotData.d.p.id, host: iotData.d.p.h, port: UInt16(iotData.d.p.p))
        cocoaMqtt.username = iotData.d.p.un
        cocoaMqtt.password = iotData.d.p.pwd
        cocoaMqtt.delegate = self
        cocoaMqtt.enableSSL = true
        
        if mqttConfig.mqttConnectionType == .certificateAuthentication && ( iotData.d.at == AuthType.caSigned || iotData.d.at == AuthType.caSelfSigned) {
            guard let mqttCertiConfig = mqttConfig.certificateConfig else {
                printLogs(msg: "CertificateConfig is empty...")
                return
            }
            var sslSettings: [String: NSObject] = [:]
            let path = getFilePath(path: mqttCertiConfig.certificatePath)
            let clientCertificate = getClientCertFromP12File(pathCertificate: path, certPassword: mqttCertiConfig.certificatePassword)
            sslSettings[kCFStreamSSLCertificates as String] = clientCertificate
            cocoaMqtt.sslSettings = sslSettings
            cocoaMqtt.allowUntrustCACertificate = true
        }
        self.cocoaMqtt = cocoaMqtt
    }
    
    func connectCocoaMqtt(completion: @escaping (Bool) -> Void) {
        _ = cocoaMqtt?.connect()
        connctionCompletion = completion
    }
    
    func disconnectCocoaMqtt(completion: @escaping (Bool) -> Void) {
        cocoaMqtt?.disconnect()
        disconnectedSuccess = completion
    }
    
    func publishCocoaMqtt(topic: String, message: String, completion: @escaping (Bool) -> Void) {
        cocoaMqtt?.publish(topic, withString: message, qos: .qos1, retained: true)
        publishedSuccess = completion
    }
    
    func subscribeCocoaMqtt(topic: String, completion: @escaping (Bool) -> Void) {
        cocoaMqtt?.subscribe(topic, qos: CocoaMQTTQoS.qos1)
        subscribedSuccess = completion
    }
    
    func unSubscribeCocoaMqtt(topic: String, completion: @escaping (Bool) -> Void) {
        cocoaMqtt?.unsubscribe(topic)
        unsubscribedSuccess = completion
    }
    
    //MARK:- Private methods
    fileprivate func getClientCertFromP12File(pathCertificate: String, certPassword: String) -> CFArray? {
        guard let p12Data = NSData(contentsOfFile: pathCertificate) else { return nil }
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                printLogs(msg: "ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                printLogs(msg: "Failed to open the certificate file-2: \(pathCertificate)")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        
        return certArray
    }
    
    fileprivate func getFilePath(path: Any) -> String {
        if let pathFile = path as? String {
            return pathFile
        } else if let urlFile = path as? URL {
            return urlFile.path
        }
        return ""
    }
    
    fileprivate func printLogs(msg: String) {
        print("MQTT: \(msg)")
    }
}

extension MqttClientService: CocoaMQTTDelegate {
    
    // MQTT Connection
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            guard let config =  mqttConfigObj else { return }
            // Subscribe to 3 topics
            subscribeCocoaMqtt(topic: config.iotData.d.p.sub, completion:{_ in })
            subscribeCocoaMqtt(topic: IoTConnectManager.sharedInstance.twinPropertySubTopic, completion:{_ in })
            subscribeCocoaMqtt(topic: IoTConnectManager.sharedInstance.twinResponseSubTopic, completion:{_ in })
            
            // Check for offline storage
        }
    }
    
    // Connect states
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        if state == .connected {
            connctionCompletion?(true)
        } else if state == .disconnected {
            connctionCompletion?(false)
        }
    }
    
    // Publish message
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        publishedSuccess?(true)
    }
    
    // Receive messages
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let data = message.string?.data(using: .utf8) {
            guard (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) != nil else {
                printLogs(msg: "Invalid json formate")
                return
            }
            // decode message
            
            
        } else {
            printLogs(msg: "Unrecognized message: \(String(describing: message.string))")
        }
    }
    
    // Subscribe Topics
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        if failed.count == 0 {
            subscribedSuccess?(true)
        } else {
            subscribedSuccess?(false)
        }
    }
    
    // Unsubscribe Topics
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        unsubscribedSuccess?(true)
    }
    
    // Connection disconnected successfully
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if err == nil {
            disconnectedSuccess?(true)
        } else {
            disconnectedSuccess?(false)
        }
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
}
