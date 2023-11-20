//
//  HTTPService.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/23/21.
//

import Foundation

class HTTPService: HTTPManagerDelegate {
    
    static let shared = HTTPService()
    let session = URLSession.shared
    
    func makeRequest(config: HTTPRequestConfig, success: @escaping (Data) -> (), failure: @escaping (Error) -> ()) {
        if (checkInternetAvailable()) {
            if let request = getUrlRequest(config: config) {
                let task = session.dataTask(with: request) { (data, response, error) in
                    self.handleResponse(data: data, response: response, error: error, success: success, failure: failure)
                }
                task.resume()
            } else {
                failure(GenericErrors.unableToCreateRequest)
            }
        } else {
            // send Internet is not available
            failure(GenericErrors.noInternetConnection)
        }
    }
    
    fileprivate func getUrlRequest(config: HTTPRequestConfig) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = HTTPScheme.secure
        components.host = config.baseUrl
        // Append path values
        if let path = config.path {
            components.path = path
        }
        
        //Add url params if provided
        if let urlParams = config.urlParams {
            var quaryArray = [URLQueryItem]()
            for urlParam in urlParams {
                quaryArray.append(URLQueryItem(name: urlParam.key, value: urlParam.value))
            }
            components.queryItems = quaryArray
        }
        guard let apiUrl = components.url else { return nil }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = config.method.rawValue
        
        // Assign headers
        request.setValue(HTTPHeaderValues.json, forHTTPHeaderField: HTTPHeaderKeys.contentType)
        request.setValue(HTTPHeaderValues.json, forHTTPHeaderField: HTTPHeaderKeys.accept)
        if let headers = config.headers {
            request.allHTTPHeaderFields = headers
        }
        
        //Add body params if provided
        if let bodyParams = config.body {
            if bodyParams.count > 0 {
                let jsonData = try? JSONSerialization.data(withJSONObject: bodyParams, options: [])
                request.httpBody = jsonData
                request.setValue("\(UInt(bodyParams.count))", forHTTPHeaderField: HTTPHeaderKeys.contentLength)
            }
        }
        return request
    }
    
    fileprivate func handleResponse(data:Data?,
                                    response:URLResponse?,
                                    error:Error?,
                                    success: @escaping (Data) -> (),
                                    failure: @escaping (Error) -> ()) {
        if error != nil || data == nil {
            failure(error!)
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            // error from server
            failure(GenericErrors.unacceptableStatusCode)
            return
        }
        
        guard let data = data else {
            failure(GenericErrors.emptyData)
            return
        }
        
        success(data)
    }
    
    fileprivate func checkInternetAvailable() -> Bool {
        let networkStatus = try! Reachability().connection
        switch networkStatus {
//        case nil:
//            return false
        case .cellular:
            return true
        case .wifi:
            return true
        case .none, .unavailable:
            return false
        }
    }
}
