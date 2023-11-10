//
//  IoTConnectDelegate.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

protocol IoTConnectDelegate {
    func conncetionSuccess()
    func sendDataSuccess()
    func sendLogSuccess()
    func sendAcknowledgementSuccess()
    func failed(error: Error)
}
