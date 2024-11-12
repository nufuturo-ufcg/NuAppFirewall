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
    case ruleAlreadyExists
}

class RulesManager {
    
    var rules: [String: [String: Rule]] = [:]
    let dataConverter = DataConverter()
    
    func loadRules(fileName: String, fileType: FileType) {
        guard let dictionary = dataConverter.readData(from: fileName, ofType: fileType) else {
            LogManager.logManager.log("Failed to read JSON data")
            return
        }
        
        rules.removeAll()
        
        for (path, rulesArray) in dictionary {
            guard let rulesArray = rulesArray as? [[String: Any]] else { continue }
            
            for ruleData in rulesArray {
                guard let action = ruleData["action"] as? String,
                      let destinations = ruleData["destinations"] as? [[String]] else { continue }
                
                for destination in destinations {
                    let endpoint = destination[0]
                    let port = destination[1]
                    let destination = "\(endpoint):\(port)"
                    let ruleID = "\(path)-\(action)-\(destination)"
                    
                    if let rule = Rule(ruleID: ruleID, action: action, appLocation: path, endpoint: endpoint, port: port) {
                        do {
                            try addRule(rule)
                            LogManager.logManager.log("Added rule with ID: \(ruleID)", level: .debug)
                        } catch {
                            LogManager.logManager.log("Failed to add rule with ID: \(ruleID): \(error)", level: .debug)
                        }
                    }
                }
            }
        }
    }
    
    func removeRule(appPath: String, destination: String) -> Rule? {
        guard var appRules = rules[appPath], let removedRule = appRules.removeValue(forKey: destination) else {
            return nil
        }
        
        if appRules.isEmpty { rules.removeValue(forKey: appPath) }
        else { rules[appPath] = appRules }
        return removedRule
    }
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else { throw RulesManagerError.invalidRule }
        let destination = "\(rule.endpoint):\(rule.port)"
        
        if rules[rule.appLocation]?[destination] != nil {
            throw RulesManagerError.ruleAlreadyExists
        }
        
        rules[rule.appLocation, default: [:]][destination] = rule
    }
    
    func getRule(appPath: String, url: String, host: String, ip: String, port: String) -> Rule? {
        if let rule = getGeneralRule(appPath, preferBlock: true) { return rule }
        if let rule = getRuleByUrl(appPath, url, port, preferBlock: true) { return rule }
        if let rule = getRuleByHost(appPath, host, port, preferBlock: true) { return rule }
        if let rule = getRuleByIp(appPath, ip, port, preferBlock: true) { return rule }
        
        if let rule = getGeneralRule(appPath) { return rule }
        if let rule = getRuleByUrl(appPath, url, port) { return rule }
        if let rule = getRuleByHost(appPath, host, port) { return rule }
        if let rule = getRuleByIp(appPath, ip, port) { return rule }
        
        return nil
    }
    
    private func getGeneralRule(_ appPath: String, preferBlock: Bool = false) -> Rule? {
        if let generalRule = rules[appPath]?["\(Consts.any):\(Consts.any)"], (!preferBlock || generalRule.action == Consts.verdictBlock) {
            return generalRule
        }
        
        if let generalRule = rules[appPath]?["\(Consts.any):\(Consts.any)"] { return generalRule }
        
        return nil
    }

    private func getRuleByUrl(_ appPath: String, _ url: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericUrlKey = "\(url):\(Consts.any)"
        if let genericUrlRule = rules[appPath]?[genericUrlKey], (!preferBlock || genericUrlRule.action == Consts.verdictBlock) {
            return genericUrlRule
        }
        
        let specificUrlKey = "\(url):\(port)"
        if let specificUrlRule = rules[appPath]?[specificUrlKey], (!preferBlock || specificUrlRule.action == Consts.verdictBlock) {
            return specificUrlRule
        }
        
        return nil
    }

    private func getRuleByHost(_ appPath: String, _ host: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericHostKey = "\(host):\(Consts.any)"
        if let genericHostRule = rules[appPath]?[genericHostKey], (!preferBlock || genericHostRule.action == Consts.verdictBlock) {
            return genericHostRule
        }
        
        let specificHostKey = "\(host):\(port)"
        if let specificHostRule = rules[appPath]?[specificHostKey], (!preferBlock || specificHostRule.action == Consts.verdictBlock) {
            return specificHostRule
        }
        
        return nil
    }

    private func getRuleByIp(_ appPath: String, _ ip: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericIpKey = "\(ip):\(Consts.any)"
        if let genericIpRule = rules[appPath]?[genericIpKey], (!preferBlock || genericIpRule.action == Consts.verdictBlock) {
            return genericIpRule
        }
        
        let specificIpKey = "\(ip):\(port)"
        if let specificIpRule = rules[appPath]?[specificIpKey], (!preferBlock || specificIpRule.action == Consts.verdictBlock) {
            return specificIpRule
        }
        
        return nil
    }
}
