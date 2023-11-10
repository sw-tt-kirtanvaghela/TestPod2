//
//  MqttConfig.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/27/21.
//

import Foundation

struct CocoaMqttConfig {
    let cpid: String
    let uniqueId: String
    let mqttConnectionType: MqttConnectionType
    let certificateConfig: CertificateConfig?
    let offlineStorageConfig: OfflineStorageConfig?
    let iotData: IoTData
}
