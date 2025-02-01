//
//  RulesLoader.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 01/02/25.
//

import Foundation

class RulesLoader {
    
    let dataConverter = DataConverter()
    
    func loadData(fileName: String, fileType: FileType) -> [String: Any]? {
        guard let managedData = dataConverter.readManagedData() else {
            LogManager.logManager.log("Failed to read managed data")
            
            guard let fallbackData = dataConverter.readData(from: fileName, ofType: fileType) else {
                LogManager.logManager.log("Failed to read JSON data")
                return nil
            }
            
            return fallbackData
        }
        
        return managedData
    }
    
    func loadRules(fileName: String, fileType: FileType) -> [String: [String: Rule]] {
        var rules: [String: [String: Rule]] = [:]
        var applications: Set<String> = []
        
        guard let dictionary = loadData(fileName: fileName, fileType: fileType) else {
            return rules
        }
        
        for (path, rulesArray) in dictionary {
            guard let rulesArray = rulesArray as? [[String: Any]] else { continue }
            
            for ruleData in rulesArray {
                guard let action = ruleData["action"] as? String,
                      let destinations = ruleData["destinations"] as? [[String]],
                      let identifier = ruleData["identifier"] as? String else { continue }
                
                for destination in destinations {
                    let endpoint = destination[0]
                    let port = destination[1]
                    
                    let app = identifier != "unknown" ? identifier : path
                    if let rule = createRule(action: action, app: app, endpoint: endpoint, port: port) {
                        rules[app, default: [:]][rule.destination] = rule
                        applications.insert(app)
                    }
                }
            }
        }
        
        return rules
    }
    
    private func createRule(action: String, app: String, endpoint: String, port: String) -> Rule? {
        let destination = "\(endpoint):\(port)"
        let ruleID = "\(app)-\(action)-\(destination)"
        return Rule(ruleID: ruleID, action: action, app: app, endpoint: endpoint, port: port) ?? nil
    }
}
