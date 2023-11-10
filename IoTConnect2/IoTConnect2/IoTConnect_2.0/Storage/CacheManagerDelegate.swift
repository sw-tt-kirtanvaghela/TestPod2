//
//  CacheManagerDelegate.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/26/21.
//

import Foundation

protocol CacheManagerDelegate {
    func getSavedData(filename: String) -> Data?
    func saveDataToFile(data: CachProtocol, completion:@escaping (_ error: Error?) -> Void)
}
