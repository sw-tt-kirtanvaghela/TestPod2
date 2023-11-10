//
//  HTTPRequestConfig.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct HTTPRequestConfig {
    var baseUrl: String
    var path: String?
    var headers: [String: String]?
    var body: [String: Any]?
    var urlParams: [String: String]?
    var method: HTTPMethod
    
    init(baseUrl: String,
         path: String,
         headers: [String: String]? = nil,
         body: [String: Any]? = nil,
         urlParams: [String: String]? = nil,
         method: HTTPMethod) {
        self.baseUrl = baseUrl
        self.path = path
        self.headers = headers
        self.body = body
        self.urlParams = urlParams
        self.method = method
    }
}
