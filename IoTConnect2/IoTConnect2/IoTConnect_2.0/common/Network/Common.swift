//
//  Common.swift
//  IoTConnect


import Foundation

class Common {
    
    private var strCPID: String = ""
    private var strUniqueID: String = ""
    
    init(_ cpId: String, _ uniqueId: String) {
        strCPID = cpId
        strUniqueID = uniqueId
    }
    
    //MARK: Get Base URL
    func getBaseURL(strURL: String, callBack: @escaping (Bool, Any) -> ()) {
        print("getBaseURL \(strURL)")
        let dataTaskMain = URLSession.shared.dataTask(with: URL(string: strURL)!) { (data, response, error) in
            if error == nil {
               
                let errorParse: Error? = nil
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                print("getBaseURL response \(jsonData ?? "")")
                if jsonData == nil {
                    callBack(false, errorParse as Any)
                } else {
                    callBack(true, jsonData as Any)
                }
            } else {
                print("getBaseURL error \(String(describing: error))")
                callBack(false, error as Any)
            }
        }
        dataTaskMain.resume()
    }
    //MARK: Device Sync Call
    func makeSyncCall(withBaseURL strURL: String, withData dictToPass: [AnyHashable: Any]?, withBlock completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        var urlRequest : URLRequest = URLRequest(url: URL(string: strURL)!)
//        var postData: Data? = nil
//        if let aPass = dictToPass {
//            postData = try? JSONSerialization.data(withJSONObject: aPass, options: .prettyPrinted)
//        }
        // Convert POST string parameters to data using UTF8 Encoding
        //kirtan
        urlRequest.httpMethod = "GET"//"POST"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.setValue("\(UInt(postData!.count))", forHTTPHeaderField: "Content-Length")
//        urlRequest.httpBody = postData
        
        print("makeSyncCall \(strURL)")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            print("makeSyncCall response\(String(describing: response))")
            completionHandler(data, response, error)
        }
        dataTask.resume()
        
    }
    //MARK: - Date Formatted Methods
    func now() -> String {
        return toString(fromDateTime: Date())
    }
    private func toString(fromDateTime datetime: Date?) -> String {
        // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
        // Example: 2013-10-25T06:59:43.431Z
        let dateFormatter = DateFormatter()
        if let anAbbreviation = NSTimeZone(abbreviation: "UTC") {
            dateFormatter.timeZone = anAbbreviation as TimeZone
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        var dateTimeInIsoFormatForZuluTimeZone: String? = nil
        if let aDatetime = datetime {
            dateTimeInIsoFormatForZuluTimeZone = dateFormatter.string(from: aDatetime)
        }
        return dateTimeInIsoFormatForZuluTimeZone!
    }
    //MARK: - Error/Info Logs Methods
    func manageDebugLog(code: Any, uniqueId: String, cpId: String, message: String, logFlag: Bool, isDebugEnabled: Bool) {
        print("code: \(code)")
        if isDebugEnabled {
            let debugPathBasUrl = "logs/debug/"
            let debugErrorLogPath = debugPathBasUrl + "error.txt"
            let debugInfoLogPath = debugPathBasUrl + "info.txt"
            var strMessage = message
            if !logFlag && message == "" {
                strMessage = (code as! Log.Errors).rawValue
            } else if logFlag && message == "" {
                strMessage = (code as! Log.Info).rawValue
            }
            let logText = "\n[\(code)] \(now()) [\(cpId)_\(uniqueId)] : \(strMessage)"
            let fileManager = FileManager.default
            if !logFlag {//...Error Log
                do {
                    let urlErrorFilePath = getDocumentsDirectory().appendingPathComponent(debugErrorLogPath)
                    if fileManager.fileExists(atPath: urlErrorFilePath.path) {
                        var input = try String(contentsOf: urlErrorFilePath)
                        input.append(logText)
                        try input.write(to: urlErrorFilePath, atomically: true, encoding: .utf8)
                    } else {
                        try logText.write(to: urlErrorFilePath, atomically: true, encoding: .utf8)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {//...Info Log
                do {
                    let urlInfoFilePath = getDocumentsDirectory().appendingPathComponent(debugInfoLogPath)
                    if fileManager.fileExists(atPath: urlInfoFilePath.path) {
                        var input = try String(contentsOf: urlInfoFilePath)
                        input.append(logText)
                        try input.write(to: urlInfoFilePath, atomically: true, encoding: .utf8)
                    } else {
                        try logText.write(to: urlInfoFilePath, atomically: true, encoding: .utf8)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    //MARK: - Custom Methods
    func deleteAllLogFile(logPath: String, debugYN: Bool) {
        do {
            var files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().appendingPathComponent(logPath).path)
            print("deleteAllLogFile-directoryContents-Before: \(files)")
            if files.contains(".DS_Store") {
                files.remove(at: files.firstIndex(of: ".DS_Store")!)
            }
            print("deleteAllLogFile-directoryContents-After: \(files)")
            if files.count > 0 {
                files.forEach { (file) in
                    do {
                        try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent(logPath + file))
                        manageDebugLog(code: Log.Info.INFO_OS04, uniqueId: strUniqueID, cpId: strCPID, message: "", logFlag: true, isDebugEnabled: debugYN)
                    } catch {
                        print("deleteAllLogFile-Remove-error.localizedDescription: \(error.localizedDescription)")
                        manageDebugLog(code: Log.Errors.ERR_OS01, uniqueId: strUniqueID, cpId: strCPID, message:error.localizedDescription, logFlag: false, isDebugEnabled: debugYN)
                    }
                }
            }
        } catch {
            print("deleteAllLogFile-error.localizedDescription: \(error.localizedDescription)")
            manageDebugLog(code: Log.Errors.ERR_OS01, uniqueId: strUniqueID, cpId: strCPID, message:error.localizedDescription, logFlag: false, isDebugEnabled: debugYN)
        }
    }
    func getAttributes(dictSyncResponse: [String:Any], callBack: @escaping ([String:Any]?, String) -> ()) {
        DispatchQueue.main.async {
            let newAttributeObj = dictSyncResponse[keyPath: "p.topics.di"]
            //dictSyncResponse["att"] as! [[String:Any]]
//            let isEdgeDevice = dictSyncResponse["ee"] as! Bool
            
            
//            newAttributeObj = newAttributeObj.map { (attributes) -> [String:Any] in
//                var dataAttributes = attributes
//                if !isEdgeDevice {
//                    dataAttributes.removeValue(forKey: "tw")
//                    dataAttributes.removeValue(forKey: "agt")
//                }
//                dataAttributes["d"] = (dataAttributes["d"] as! [[String:Any]]).map({ (data) -> [String : Any] in
//                    var dataDevice = data
//                    if !isEdgeDevice {
//                        dataDevice.removeValue(forKey: "tw")
//                        dataDevice.removeValue(forKey: "agt")
//                    }
//                    dataDevice.removeValue(forKey: "sq")
//                    return dataDevice
//                })
//                return dataAttributes
//            }
            callBack(["attribute": newAttributeObj ?? ""], "Data sync successfully.")
        }
    }
    func getSubStringFor(strToProcess: String, indStart: Int, indEnd: Int) -> String {
        return String(strToProcess[strToProcess.index(strToProcess.startIndex, offsetBy:indStart)..<strToProcess.index(strToProcess.endIndex, offsetBy: indEnd)])
    }
    func createDirectoryFoldersForLogs() {
        createPredeffinedLogDirecctories(folderName: "logs/offline")
        createPredeffinedLogDirecctories(folderName: "logs/debug")
    }
    func createPredeffinedLogDirecctories(folderName: String)  {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    let logText = "[ERR_IN01] \(now()) [\(strCPID)_\(strUniqueID)] : \(error.localizedDescription)"
                    print(logText)
                }
            }
            // Folder either exists, or was created. Return URL
            print("FolderURL-(\(folderName): \(folderURL)")
        }
        // Will only be called if document directory not found
    }
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    func checkForIfFileExistAtPath(filePath: Any) -> Bool {
        if let pathFile = filePath as? String {
            return FileManager.default.fileExists(atPath: pathFile)
        } else if let urlFile = filePath as? URL {
            return FileManager.default.fileExists(atPath: urlFile.path)
        }
        return false
    }
    func getClientCertFromP12File(pathCertificate: String, certPassword: String) -> CFArray? {
        // get p12 file path
        /*let resourcePath = getDocumentsDirectory().appendingPathComponent(certName).path
        
        guard let filePath = resourcePath as? String, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file-1: \(certName)")
            return nil
        }*/
        let p12Data = NSData(contentsOfFile: pathCertificate)!
        
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                print("Failed to open the certificate file-2: \(pathCertificate)")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        
        return certArray
    }
    func getFilePath(_ filePath: Any) -> String {
        if let pathFile = filePath as? String {
            return pathFile
        } else if let urlFile = filePath as? URL {
            return urlFile.path
        }
        return ""
    }
    func dataTypeToString(value: Int) -> String {
        switch (value) {
        case DataType.dtNumber: // 0 = number
            return "number"
        case DataType.dtString: // 1 = string
            return "string"
        case DataType.dtObject: // 2 = object
            return "object";
        default:
            return ""
        }
    }
    func setEdgeConfiguration(attributes: [[String:Any]], uniqueId: String, devices: [[String:Any]], callback: @escaping ([String:Any]) -> ()) {
        var mainObj: [String:Any] = [:]
        var inObj: [[String:Any]] = []
        attributes.forEach { (attribute) in
            if attribute["p"] as! String == "" {
                (attribute["d"] as! [[String:Any]]).forEach { (attr) in
                    let tagMatchedDevice = devices.filter { (o) -> Bool in
                        return o["tg"] as! String == attr["tg"] as! String
                    }
                    tagMatchedDevice.forEach { (device) in
                        let edgeAttributeKey = (device["id"] as! String) + "-" + (attr["ln"] as! String) + "-" + (attr["tg"] as! String)
                        let attrTag = attr["tg"] as! String
                        var attrObj: [String:Any] = [:]
                        attrObj["parent"] = attribute["p"]
                        attrObj["sTime"] = ""
                        attrObj["data"] = []
                        let dataSendFrequency = attr["tw"] as! String
                        let lastChar = dataSendFrequency.last
                        let strArray = ["s", "m", "h"].joined(separator: ",")
                        if strArray.contains(lastChar!) {
                            let tumblingWindowTime = dataSendFrequency.dropLast()
                            let obj: [String:Any] = [
                                "tumblingWindowTime": tumblingWindowTime,
                                "lastChar": lastChar as Any,
                                "edgeAttributeKey": edgeAttributeKey,
                                "uniqueId": uniqueId,
                                "attrTag": attrTag,
                                "devices": devices
                            ]
                            inObj.append(obj)
                        }
                        
                        var setAttributeObj: [String:Any] = [:]
                        for (key, _) in SDKConstants.aggrigacaseteType {
                            setAttributeObj["localName"] = attr["ln"]
                            if attr["agt"] != nil {
                                if key == "count" {
                                    setAttributeObj[key] = 0
                                } else {
                                    setAttributeObj[key] = ""
                                }
                            }
                        }
                        var dataToSet = attrObj["data"] as! [[String:Any]]
                        dataToSet.append(setAttributeObj)
                        attrObj["data"] = dataToSet
                        mainObj[edgeAttributeKey] = attrObj
                    }
                }
            } else {
                let tagMatchedDevice = devices.filter { (o) -> Bool in
                    return o["tg"] as! String == attribute["tg"] as! String
                }
                tagMatchedDevice.forEach { (device) in
                    var attrObj: [String:Any] = [:]
                    attrObj["parent"] = attribute["p"]
                    attrObj["sTime"] = ""
                    attrObj["data"] = []
                    let edgeAttributeKey = (device["id"] as! String) + "-" + (attribute["p"] as! String) + "-" + (attribute["tg"] as! String)
                    let attrTag = attribute["tg"]
                    let dataSendFrequency = attribute["tw"] as! String
                    let lastChar = dataSendFrequency.last
                    let tumblingWindowTime = dataSendFrequency.dropLast()
                    
                    (attribute["d"] as! [[String:Any]]).forEach { (attr) in
                        var setAttributeObj: [String:Any] = [:]
                        for (key, _) in SDKConstants.aggrigacaseteType {
                            setAttributeObj["localName"] = attr["ln"]
                            if attribute["agt"] != nil {
                                if key == "count" {
                                    setAttributeObj[key] = 0
                                } else {
                                    setAttributeObj[key] = ""
                                }
                            }
                        }
                        var dataToSet = attrObj["data"] as! [[String:Any]]
                        dataToSet.append(setAttributeObj)
                        attrObj["data"] = dataToSet
                    }
                    
                    mainObj[edgeAttributeKey] = attrObj
                    let strArray = ["s", "m", "h"].joined(separator: ",")
                    if strArray.contains(lastChar!) {
                        let obj: [String:Any] = [
                            "tumblingWindowTime": tumblingWindowTime,
                            "lastChar": lastChar as Any,
                            "edgeAttributeKey": edgeAttributeKey,
                            "uniqueId": uniqueId,
                            "attrTag": attrTag as Any,
                            "devices": devices
                        ]
                        inObj.append(obj)
                    }
                }
            }
        }
        
        callback(["status": true, "data": ["mainObj": mainObj, "intObj": inObj], "message": "Edge data set and started the interval as per attribute's tumbling window."])
    }
    
    func setIntervalForEdgeDevice(tumblingWindowTime: String, timeType: String, edgeAttributeKey: String, uniqueId: String, attrTag: String, env: String, offlineConfig: OfflineStorageOption, intervalObj: [Any], cpId: String, isDebug: Bool) {}
}

//extension
struct KeyPath {
    var segments: [String]
    
    var isEmpty: Bool { return segments.isEmpty }
    var path: String {
        return segments.joined(separator: ".")
    }
    
    /// Strips off the first segment and returns a pair
    /// consisting of the first segment and the remaining key path.
    /// Returns nil if the key path has no segments.
    func headAndTail() -> (head: String, tail: KeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        let head = tail.removeFirst()
        return (head, KeyPath(segments: tail))
    }
}

/// Initializes a KeyPath with a string of the form "this.is.a.keypath"
extension KeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension KeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

// Needed because Swift 3.0 doesn't support extensions with concrete
// same-type requirements (extension Dictionary where Key == String).
protocol StringProtocol {
    init(string s: String)
}

extension String: StringProtocol {
    public init(string s: String) {
        self = s
    }
}


extension Dictionary where Key: StringProtocol {
    subscript(keyPath keyPath: KeyPath) -> Any? {
        get {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return nil
            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                return self[key]
            case let (head, remainingKeyPath)?:
                // Key path has a tail we need to traverse.
                let key = Key(string: head)
                switch self[key] {
                case let nestedDict as [Key: Any]:
                    // Next nest level is a dictionary.
                    // Start over with remaining key path.
                    return nestedDict[keyPath: remainingKeyPath]
                default:
                    // Next nest level isn't a dictionary.
                    // Invalid key path, abort.
                    return nil
                }
            }
        }
        set {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return
            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                self[key] = newValue as? Value
            case let (head, remainingKeyPath)?:
                let key = Key(string: head)
                let value = self[key]
                switch value {
                case var nestedDict as [Key: Any]:
                    // Key path has a tail we need to traverse
                    nestedDict[keyPath: remainingKeyPath] = newValue
                    self[key] = nestedDict as? Value
                default:
                    // Invalid keyPath
                    return
                }
            }
        }
    }
}
