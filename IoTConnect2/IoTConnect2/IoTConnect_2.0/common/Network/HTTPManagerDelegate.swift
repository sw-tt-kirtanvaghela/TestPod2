//
//  HTTPManagerDelegate.swift
//  IoTConnect


import Foundation

protocol HTTPManagerDelegate {
    func makeRequest(config: HTTPRequestConfig,
                     success: @escaping (Data) -> (),
                     failure: @escaping (Error) -> ())
}
