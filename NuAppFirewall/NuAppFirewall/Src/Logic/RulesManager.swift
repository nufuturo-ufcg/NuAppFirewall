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
                      let endpoint = ruleData["endpoint"] as? String,
                      let path = ruleData["path"] as? String,
                      let port = ruleData["port"] as? String else {
                    continue
                }
                
                let destination = "\(endpoint):\(port)"
                let ruleID = "\(path)-\(destination)"
                
                if let rule = Rule(ruleID: ruleID, action: action, appLocation: path, endpoint: endpoint, port: port) {
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
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else {
            throw RulesManagerError.invalidRule
        }
        
        let destination = "\(rule.endpoint):\(rule.port)"
        rules[rule.appLocation, default: [:]][destination] = rule
    }
    
    func getRule(appPath: String, url: String, host: String, ip: String, port: String) -> Rule? {
        if let generalRule = rules[appPath]?["\(Consts.any):\(Consts.any)"], generalRule.action == Consts.verdictBlock {
            return generalRule
        }
        
        if let rule = getRuleByIp(appPath, ip, port) { return rule}
        
        if let rule = getRuleByUrl(appPath, url, port) { return rule}
        
        if let rule = getRuleByHost(appPath, host, port) { return rule}
        
        return nil
    }
    
    private func getRuleByUrl(_ appPath: String, _ url: String, _ port: String) -> Rule? {
        let genericUrlKey = "\(url):\(Consts.any)"
        if let genericUrlRule = rules[appPath]?[genericUrlKey] { return genericUrlRule}
        
        let especificUrlKey = "\(url):\(port)"
        if let especificUrlRule = rules[appPath]?[especificUrlKey] { return especificUrlRule}
        
        return nil
    }
    
    private func getRuleByHost(_ appPath: String, _ host: String, _ port: String) -> Rule? {
        let genericHostKey = "\(host):\(Consts.any)"
        if let genericHostRule = rules[appPath]?[genericHostKey] { return genericHostRule}
        
        let especificHostKey = "\(host):\(port)"
        if let especificHostRule = rules[appPath]?[especificHostKey] { return especificHostRule}
        
        return nil
    }
    
    private func getRuleByIp(_ appPath: String, _ ip: String, _ port: String) -> Rule? {
        let genericIpKey = "\(ip):\(Consts.any)"
        if let genericIpRule = rules[appPath]?[genericIpKey] { return genericIpRule}
        
        let especificIpKey = "\(ip):\(port)"
        if let especificIpRule = rules[appPath]?[especificIpKey] { return especificIpRule}
        
        return nil
    }
}
