//
//  CacheService.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/26/21.
//

import Foundation

class CacheService {
    static let shared = CacheService(destination: .documentDirectory)
    
    let destination: URL
    private let queue = OperationQueue()
    
    enum CacheDestination {
        case cacheDirectory //NSCacheDirectory
        case documentDirectory //NSCacheDirectory
    }
    
    init(destination: CacheDestination) {
        switch destination {
        case .cacheDirectory:
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: cachePath)
        case .documentDirectory:
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: documentsPath)
        }
        try? FileManager.default.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
    }
    
    func saveOnDevice(data: CachProtocol, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        var url: URL?
        var error: Error?
        
        let operation = BlockOperation {
            
            do {
                let filePath = self.destination.appendingPathComponent(data.fileName)
                try data.data.write(to: filePath, options: [.atomicWrite])
                url = filePath
                print("Filepath: \(String(describing: url?.absoluteString))")
            } catch let err {
                error = err
            }
        }
        operation.completionBlock = {
            completion(url, error)
        }
        queue.addOperation(operation)
    }
    
    func retriveDataFromFile(fileName: String) -> Data? {
        let filePath = destination.appendingPathComponent(fileName, isDirectory: false)
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return data
    }
    
    func deleteCachedFile(theFile: String) {
        let url = self.destination.appendingPathComponent(theFile, isDirectory: false)
        let urlString = url.path
        deleteFile(path: urlString)
    }
    
    //MARK:- Private functions
    fileprivate func checkCachedFile(theFile: String) -> Bool {
        let url = self.destination.appendingPathComponent(theFile, isDirectory: false)
        let urlString = url.path
        return findIfFileExists(path: urlString)
    }
    
    fileprivate func deleteFile(path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    fileprivate func findIfFileExists(path: String) -> Bool{
        return FileManager.default.fileExists(atPath:path)
    }
}
