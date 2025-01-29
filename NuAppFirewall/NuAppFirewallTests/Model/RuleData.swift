//
//  RuleData.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 23/01/25.
//

struct RuleData {
    let action: String
    let app: String
    let endpoint: String
    let port: String
    
    var destination: String {
        return "\(endpoint):\(port)"
    }
    
    var ruleID: String {
        return "\(app)-\(action)-\(destination)"
    }
}
