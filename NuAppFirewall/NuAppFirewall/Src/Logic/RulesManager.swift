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
    private var rules: [String: Rule] = [:]
    var rulesByApp: [String: [Rule]] = [:]
    
    let dataConverter = DataConverter()
    
    func loadRules(fileName: String, fileType: FileType){
        guard let dictionary = dataConverter.readData(from: fileName, ofType: fileType) else {
            LogManager.logManager.log("Failed to read JSON data")
            return
        }
        
        LogManager.logManager.log("Read JSON data: \(dictionary)")
        
        // limpa os dicionarios para evitar duplicacao
        rules.removeAll()
        rulesByApp.removeAll()
        
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
        
        if rules[rule.ruleID] == nil {
            // adiciona ao dicionario principal
            rules[rule.ruleID] = rule
            
            // adiciona ao dicionario por app path
            rulesByApp[rule.appLocation, default: []].append(rule)
        }
    }
    
    func removeRule(byID ruleID: String) -> Rule? {
        guard let rule = rules.removeValue(forKey: ruleID) else {
            return nil
        }
        
        if var appRules = rulesByApp[rule.appLocation] {
            appRules.removeAll { $0.ruleID == ruleID }
            if appRules.isEmpty {
                rulesByApp.removeValue(forKey: rule.appLocation)
            } else {
                rulesByApp[rule.appLocation] = appRules
            }
        }
        
        return rule
    }
    
    func getRule(byID ruleID: String) -> Rule? {
        return rules[ruleID]
    }
    
    func getRulesByApp(appPath: String) -> [Rule] {
        return rulesByApp[appPath] ?? []
    }
}
