//
//  LocalCache.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/26/21.
//

import Foundation

class CacheManager: CacheManagerDelegate {
    let cacheService = CacheService.shared
    
    /**
     Get saved data from the directory
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - fileName: of the cached data stored in the file system
     - returns: the decoded saved data
     */
    func getSavedData(filename: String) -> Data? {
        if let data: Data = cacheService.retriveDataFromFile(fileName: filename) {
            return data
        }
        return nil
    }
    
    /**
     Save a object in the directory selected
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: `CachProtocol` object to save in the filesystem
     - completion: callback invoked when the save finishes, it will either contain the `URL`, or the `Error` raised
     */
    func saveDataToFile(data: CachProtocol, completion: @escaping (Error?) -> Void) {
        cacheService.saveOnDevice(data: data) { (url, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    /**
     Delete saved data from the directory
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - fileName: of the cached data stored in the file system
     */
    func deleteFileFromDevice(fileName: String) {
        cacheService.deleteCachedFile(theFile: fileName)
    }
}
