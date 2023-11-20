//
//  IoTConnectConfig.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

/**
 Used for setting IoTConnect configuration.
 
 - Author:
 Devesh Mevada
 
 - Parameters:
    - cpId: Provide a company identifier
    - uniqueId: Device unique identifier
    - env: Device environment
    - sdkOptions: Device SDKOptions for SSL Certificates and Offline Storage
 
 - Returns:
    Returns nothing
 */
public struct IoTConnectConfig {
    let cpId: String
    let uniqueId: String
    let env: IoTCEnvironment
    let mqttConnectionType: MqttConnectionType
    let debugConfig: DebugConfig?
    let mqttConfig: MqttConfig?
    let sdkOptions: SDKClientOption?
    
    public init(cpId: String, uniqueId: String, env: IoTCEnvironment, mqttConnectionType: MqttConnectionType, debugConfig: DebugConfig? = nil, mqttConfig: MqttConfig? = nil, sdkOptions: SDKClientOption?) {
        self.cpId = cpId
        self.uniqueId = uniqueId
        self.env = env
        self.mqttConnectionType = mqttConnectionType
        self.debugConfig = debugConfig
        self.mqttConfig = mqttConfig
        self.sdkOptions = sdkOptions
    }
}

public struct DebugConfig {
    public var discoveryUrl: String
    public var debug: Bool = false
}

public struct MqttConfig {
    public let certificateConfig: CertificateConfig?
    public let offlineStorageConfig: OfflineStorageConfig?
}

public struct CertificateConfig {
    public let certificatePath: String
    public let certificatePassword: String
}

public struct OfflineStorageConfig {
    public var availSpaceInMb: Int = SDKConstants.osAvailSpaceInMb
    public var fileCount: Int = SDKConstants.osFileCount
    public var disabled: Bool = SDKConstants.osDisabled
}

public enum MqttConnectionType {
    case userCredntialAuthentication
    case certificateAuthentication
}
