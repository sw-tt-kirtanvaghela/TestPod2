//
//  SSLOption.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

public struct SSLOption {
    public var certificatePath: String?//This is p12 file path
    public var password: String = SDKConstants.sslPassword
}
