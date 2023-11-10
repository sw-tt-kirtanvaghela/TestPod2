//
//  MqttClientDelegate.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/27/21.
//

import Foundation

protocol MqttClientDelegate {
    func connect(completion: @escaping (Bool) -> Void)
    func disconnect(completion: @escaping (Bool) -> Void)
    func publish(topic: String, message: String, completion: @escaping (Bool) -> Void)
    func subscribe(topic: String, completion: @escaping (Bool) -> Void)
    func unsubscribe(topic: String, completion: @escaping (Bool) -> Void)
}
