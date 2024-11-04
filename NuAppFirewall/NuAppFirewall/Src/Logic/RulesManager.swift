/*
    File: RuleManager.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: This class manages a collection of `Rule` objects
        using a dictionary with rule IDs as keys.

    Created by com.nufuturo.nuappfirewall
*/

import Foundation

enum RulesManagerError: Error {
    case invalidRule
}

class RulesManager {
    private var rules: [String: [String: Rule]] = [:]
    
    let dataConverter = DataConverter()
    
    func loadRules(fileName: String, fileType: FileType){
        guard let dictionary = dataConverter.readData(from: fileName, ofType: fileType) else {
            LogManager.logManager.log("Failed to read JSON data")
            return
        }
        
        LogManager.logManager.log("Read JSON data: \(dictionary)")
        
        // limpa o dicionario para evitar duplicacao
        rules.removeAll()
        
        for (appLocation, rulesArray) in dictionary {
            
            guard let rulesArray = rulesArray as? [[String: Any]] else {
                continue
            }
            
            for ruleData in rulesArray {
                guard let action = ruleData["action"] as? String,
                      let endpoints = ruleData["endpoints"] as? [String],
                      let domains = ruleData["domains"] as? [String] else {
                    continue
                }
                
                for (index, endpoint) in endpoints.enumerated() {
                    let domain = index < domains.count ? domains[index] : domains.last!
                    let ruleID = "\(appLocation)-\(endpoint)-\(domain)"
                    if let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: endpoint, domain: domain) {
                        do {
                            try addRule(rule)
                            LogManager.logManager.log("Added rule with ID: \(ruleID)")
                        } catch {
                            LogManager.logManager.log("Failed to add rule with ID: \(ruleID)")
                        }
                    }
                }
            }
        }
    }
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else {
            throw RulesManagerError.invalidRule
        }
        
        rules[rule.appLocation, default: [:]][rule.endpoint] = rule
    }
    
    func getRule(appPath: String, endpoint: String) -> Rule? {
        return rules[appPath]?[endpoint]
    }
    
}
