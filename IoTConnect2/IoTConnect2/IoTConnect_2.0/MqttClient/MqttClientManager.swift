//
//  MqttClientManager.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/27/21.
//

import Foundation

class MqttClientManager: MqttClientDelegate {
    let mqttClientService = MqttClientService.shared
    
    init(mqttConfig: CocoaMqttConfig) {
        mqttClientService.setupMqtt(mqttConfig: mqttConfig, iotData: mqttConfig.iotData)
    }
    
    func connect(completion: @escaping (Bool) -> Void) {
        mqttClientService.connectCocoaMqtt(completion: completion)
    }
    
    func disconnect(completion: @escaping (Bool) -> Void) {
        mqttClientService.disconnectCocoaMqtt(completion: completion)
    }
    func publish(topic: String, message: String, completion: @escaping (Bool) -> Void) {
        mqttClientService.publishCocoaMqtt(topic: topic, message: message, completion: completion)
    }
    
    func subscribe(topic: String, completion: @escaping (Bool) -> Void) {
        mqttClientService.subscribeCocoaMqtt(topic: topic, completion: completion)
    }
    
    func unsubscribe(topic: String, completion: @escaping (Bool) -> Void) {
        mqttClientService.unSubscribeCocoaMqtt(topic: topic, completion: completion)
    }
}
