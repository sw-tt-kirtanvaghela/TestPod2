//
//  CachModel.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/26/21.
//

import Foundation

protocol CachProtocol {
    var fileName: String { get }
    var data: Data { get }
}
