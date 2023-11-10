//
//  CacheModel.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/26/21.
//

import Foundation

struct CacheModel: CachProtocol, Codable {
    var fileName: String
    let data: Data
}
