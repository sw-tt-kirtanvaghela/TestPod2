//
//  File.swift
//  IoTConnect_2.0
//
//  Created by kirtan.vaghela on 31/07/23.
//

import Foundation

struct ModelEdgeRule:Codable{
    let d:EdgeRuleData?
}

struct EdgeRuleData:Codable{
    let dt:String?
    let ec,ct:Int?
    let r:[EdgeRuleConditionData]?
}

struct EdgeRuleConditionData:Codable{
        let g: String?       // GUID to identify rule (To be used in 4.4                        Edge                         Rule Match )
        let es: String?     // Event Subscription GUID
        let con: String?    // The rule condition. Using a special format                           that can be parsed with IoTConnect SDKs
        let cmd: String?   // If command needs to execute on device if rule                        matched
}




