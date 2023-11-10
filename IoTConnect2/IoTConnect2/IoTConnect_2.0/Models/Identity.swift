//
//  Identity.swift
//  IoTConnect_2.0
//
//  Created by kirtan.vaghela on 21/06/23.
//

import Foundation

struct Identity: Codable {
    let d: IdentityData?
    let status: Int?
    let message: String?
}

// MARK: - D
struct IdentityData: Codable {
    let ec, ct: Int?
    let meta: Meta?
    let has: Has?
    let p: ProtocolInfo?
    let dt: String?
}

// MARK: - Has
struct Has: Codable {
    let d, attr, hasSet, r: Int?
    let ota: Int?

    enum CodingKeys: String, CodingKey {
        case d, attr
        case hasSet = "set"
        case r, ota
    }
}

// MARK: - Meta
struct Meta: Codable {
    let at: Int?
    let df: Int?
    let cd: String?
    let gtw: Gtw?
    let edge, pf: Int?
    let hwv, swv: String?
    let v: Double?
}

// MARK: - Gtw
struct Gtw: Codable {
    let tg, g: String?
}

// MARK: - P
struct ProtocolInfo: Codable {
    let n, h: String?
    let p: Int?
    let id, un, pwd: String?
    let topics: Topics?
}

// MARK: - Topics
struct Topics: Codable {
    let rpt, erpt, erm, flt: String?
    let od, hb, ack, dl: String?
    let di, c2D: String?

    enum CodingKeys: String, CodingKey {
        case rpt, erpt, erm, flt, od, hb, ack, dl, di
        case c2D = "c2d"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
