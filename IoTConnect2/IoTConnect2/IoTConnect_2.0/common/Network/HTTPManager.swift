//
//  HTTPManager.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

class HTTPManager {

    let httpService = HTTPService.shared

    func getBaseUrls(success: @escaping (Discovery) -> (), failure: @escaping (Error) -> ()) {
        let config = getRequestForBaseurl(cpid: "nine", lang: "M_ios", ver: "2.0")
        httpService.makeRequest(config: config, success: { data in
            if let jsonData = try? JSONDecoder().decode(Discovery.self, from: data) {
                success(jsonData)
            } else {
                failure(GenericErrors.unableToDecode)
            }
        }, failure: { error in
            failure(error)
        })
    }
    
    func syncCall(dynamicBaseUrl:String, cpid: String, uniqueId: String, success: @escaping (IoTData) -> (), failure: @escaping (Error) -> ()) {
        let body = [DeviceSync.Request.cpId: cpid,
                    DeviceSync.Request.uniqueId: uniqueId,
                    DeviceSync.Request.option: [DeviceSync.Request.attribute: true,
                                                DeviceSync.Request.setting: true,
                                                DeviceSync.Request.protocolKey: true,
                                                DeviceSync.Request.device: true,
                                                DeviceSync.Request.sdkConfig: true,
                                                DeviceSync.Request.rule: true]] as [String : Any]
        
        let config = getRequestForSyncCall(baseUrl: dynamicBaseUrl, body: body)
        httpService.makeRequest(config: config, success: { data in
            do {
                let jsonData = try JSONDecoder().decode(IoTData.self, from: data)
                success(jsonData)
            } catch let error {
                print(error)
                failure(GenericErrors.unableToDecode)
            }
        }, failure: { error in
            failure(error)
        })
    }
    
    
    // MARK:- All Configurations
    fileprivate func getRequestForBaseurl(cpid: String, lang: String, ver: String) -> HTTPRequestConfig {        
        return HTTPRequestConfig(baseUrl: ApiConstants.BASE_URL,
                                 path: ApiConstants.DISCOVERY_PATH + "\(cpid)" + "/lang/" + "\(lang)" + "/ver/" + "\(ver)" + "/env/" + "\(EnvironmentSelector.environment.rawValue)",
                                 headers: nil,
                                 body: nil,
                                 urlParams: nil,
                                 method: HTTPMethod.get)
    }
    
    fileprivate func getRequestForSyncCall(baseUrl:String, body: [String: Any]) -> HTTPRequestConfig {
        let newBaseUrl = baseUrl.replacingOccurrences(of: "https://", with: "")
        let components = newBaseUrl.components(separatedBy: "/")
        var updatedBaseUrl = ""
        var updatedPath = ""
        for i in 0..<components.count {
            if i == 0 {
                updatedBaseUrl = components[i]
            } else {
                updatedPath = updatedPath + "/" + components[i]
            }
        }
        return HTTPRequestConfig(baseUrl: updatedBaseUrl,
                                 path: updatedPath + ApiConstants.SYNC_PATH,
                                 headers: nil,
                                 body: body,
                                 urlParams: nil,
                                 method: HTTPMethod.post)
    }
}

