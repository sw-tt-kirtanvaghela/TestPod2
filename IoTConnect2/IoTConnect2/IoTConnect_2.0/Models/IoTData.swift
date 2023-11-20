//
//  IoTData.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/25/21.
//

import Foundation

struct IoTData: Codable {
    let d: D
    
    struct D: Codable {
        let sc: SC
        let p: P
        let d: [DD]
        let att: [ATT]
        let set: [SET]
        let r: String?
        let ota: String?
        let dtg: String
        let cpId: String
        let rc: Int
        let ee: Int
        let at: Int
        let ds: Int
    }
}

struct SC: Codable {
    let hb: HB
    let log: LOG
    let sf: Int
    let df: Int
    
    struct HB: Codable {
        let fq: Int
        let h: String
        let un: String
        let pwd: String
        let pub: String
    }
    
    struct LOG: Codable {
        let h: String
        let un: String
        let pwd: String
        let pub: String
    }
}

struct P: Codable {
    let n: String
    let h: String
    let p: Int
    let id: String
    let un: String
    let pwd: String
    let pub: String
    let sub: String
}

struct DD: Codable {
    let tg: String
    let id: String
}

struct ATT: Codable {
    let p: String
    let dt: Int?
    let agt: Int
    let tw: String
    let tg: String
    let d: [ATTD]
    
    struct ATTD: Codable {
        let ln: String
        let dt: Int
        let dv: String
        let tg: String
        let sq: Int
        let agt: Int
        let tw: String
    }
}

struct SET: Codable {
    let ln: String
    let dt: Int
    let dv: String
}

