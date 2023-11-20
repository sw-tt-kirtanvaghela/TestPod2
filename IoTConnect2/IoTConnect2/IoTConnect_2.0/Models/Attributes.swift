//
//  Attributes.swift
//  IoTConnect_2.0
//
//  Created by kirtan.vaghela on 29/06/23.
//

import Foundation

struct Attributes: Codable {
    var d: AttributesData?
}

struct AttributesData: Codable {
    var att: [Att]?
    let ct: Int?
    let dt: String?
    let ec: Int?
    var connectedTime:Date?
}

// MARK: - Att
struct Att: Codable {
    var d: [AttData]?
    let dt: Int?
    let p,tg: String?
}

struct AttData: Codable {
    let dt: Int?
    let dv, ln,tg: String?
    var tw:String?
    let sq: Int?
    var p:String? = ""
    var value:String?
    var connectedTime:Date?
}
