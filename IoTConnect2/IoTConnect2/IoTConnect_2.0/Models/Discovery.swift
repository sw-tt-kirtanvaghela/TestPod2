//
//  Discovery.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/23/21.
//

import Foundation


//kirtan
struct Discovery: Codable {
    let d: D
    let status: Int
    let message: String                                 // based on value of                                                    ec
                                                        // 0 – Success
                                                        // 1 – Invalid value of SID
                                                        // 2 – Company not found
                                                        // 3 – Subscription Expired
}

// MARK: - D
struct D: Codable {
    let ec: Int                                         // Error Code:0 – No error
    let bu: String                                      // Base URL of the                                                           Identity service
    let logMqtt: LogMqtt                                // MQTT connection                                                           details to optionally                                                     send device logging
    let logHTTPS:String?
    let pf: String

    enum CodingKeys: String, CodingKey {
        case ec, bu
        case logMqtt = "log:mqtt"
        case logHTTPS = "log:https"
        case pf
    }
}

// MARK: - LogMqtt
struct LogMqtt: Codable {
    let hn: String                                      // Hostname of MQTT                                                     broker
    let un:String                                       // Username to                                                          connect                                                             MQTT broker
    let pwd:String                                      // Password to                                                              connect                                                          MQTT broker
    let topic:String                                    // Topic on which                                                           log                                                             messages can be                                                         sent
}
