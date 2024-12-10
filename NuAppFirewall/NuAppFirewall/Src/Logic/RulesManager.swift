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
                      let bundleID = ruleData["identifier"] as? String,
                      let destinations = ruleData["destinations"] as? [[String]] else { continue }
                
                let application = bundleID != "unknown" ? bundleID : path
                
                for destination in destinations {
                    let endpoint = destination[0]
                    let port = destination[1]
                    let destination = "\(endpoint):\(port)"
                    let ruleID = "\(application)-\(action)-\(destination)"
                    
                    if let rule = Rule(ruleID: ruleID, action: action, appIdentifier: application, endpoint: endpoint, port: port) {
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
    
    func removeRule(application: String, destination: String) -> Rule? {
        guard var appRules = rules[application], let removedRule = appRules.removeValue(forKey: destination) else {
            return nil
        }
        
        if appRules.isEmpty { rules.removeValue(forKey: application) }
        else { rules[application] = appRules }
        return removedRule
    }
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else { throw RulesManagerError.invalidRule }
        let destination = "\(rule.endpoint):\(rule.port)"
        
        if rules[rule.application]?[destination] != nil {
            throw RulesManagerError.ruleAlreadyExists
        }
        
        rules[rule.application, default: [:]][destination] = rule
    }
    
    func getRule(appPath: String, bundleID: String, url: String, host: String, ip: String, port: String) -> Rule? {
        if let rule = getGeneralRule(appPath, bundleID, preferBlock: true) { return rule }
        if let rule = getRuleByUrl(appPath, bundleID, url, port, preferBlock: true) { return rule }
        if let rule = getRuleByHost(appPath, bundleID, host, port, preferBlock: true) { return rule }
        if let rule = getRuleByIp(appPath, bundleID, ip, port, preferBlock: true) { return rule }
        
        if let rule = getGeneralRule(appPath, bundleID) { return rule }
        if let rule = getRuleByUrl(appPath, bundleID, url, port) { return rule }
        if let rule = getRuleByHost(appPath, bundleID, host, port) { return rule }
        if let rule = getRuleByIp(appPath, bundleID, ip, port) { return rule }
        
        return nil
    }
    
    private func getGeneralRule(_ appPath: String, _ bundleID: String, preferBlock: Bool = false) -> Rule? {
        // Although getRuleBySubstring can retrieve a rule using the full path,
        // this conditional is retained to prioritize efficiency.
        if let generalRuleByBundleID = rules[bundleID]?["\(Consts.any):\(Consts.any)"], (!preferBlock || generalRuleByBundleID.action == Consts.verdictBlock) {
            return generalRuleByBundleID
        }
        
        if let generalRuleByPath = rules[appPath]?["\(Consts.any):\(Consts.any)"], (!preferBlock || generalRuleByPath.action == Consts.verdictBlock) {
            return generalRuleByPath
        }
        
        let ruleBySubstring = getRuleBySubstring(appPath, "\(Consts.any):\(Consts.any)")
        
        return ruleBySubstring
    }
    
    private func getRuleBySubstring(_ appPath: String, _ appDestination: String) -> Rule? {
        var allowRule: Rule? = nil;
        var blockRule: Rule? = nil;
        
        for (path, destinations) in rules {
            if appPath.range(of: path) != nil {
                for (destination, rule) in destinations {
                    if appDestination == destination {
                        if rule.action == Consts.verdictAllow && allowRule == nil {
                            allowRule = rule
                        }
                        else if rule.action == Consts.verdictBlock {
                            blockRule = rule
                            return blockRule
                        }
                    }
                }
            }
        }
        return allowRule
    }

    private func getRuleByUrl(_ appPath: String, _ bundleID: String, _ url: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericUrlKey = "\(url):\(Consts.any)"
        let specificUrlKey = "\(url):\(port)"
        
        if let genericUrlRuleByBundleID = rules[bundleID]?[genericUrlKey], (!preferBlock || genericUrlRuleByBundleID.action == Consts.verdictBlock) {
            return genericUrlRuleByBundleID
        }
        if let specificUrlRuleByBundleID = rules[bundleID]?[specificUrlKey], (!preferBlock || specificUrlRuleByBundleID.action == Consts.verdictBlock) {
            return specificUrlRuleByBundleID
        }
        
        if let genericUrlRuleByPath = rules[appPath]?[genericUrlKey], (!preferBlock || genericUrlRuleByPath.action == Consts.verdictBlock) {
            return genericUrlRuleByPath
        }
        if let specificUrlRuleByPath = rules[appPath]?[specificUrlKey], (!preferBlock || specificUrlRuleByPath.action == Consts.verdictBlock) {
            return specificUrlRuleByPath
        }
        
        return nil
    }

    private func getRuleByHost(_ appPath: String, _ bundleID: String, _ host: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericHostKey = "\(host):\(Consts.any)"
        let specificHostKey = "\(host):\(port)"
        
        if let genericHostRuleByBundleID = rules[bundleID]?[genericHostKey], (!preferBlock || genericHostRuleByBundleID.action == Consts.verdictBlock) {
            return genericHostRuleByBundleID
        }
        if let specificHostRuleByBundleID = rules[bundleID]?[specificHostKey], (!preferBlock || specificHostRuleByBundleID.action == Consts.verdictBlock) {
            return specificHostRuleByBundleID
        }
        
        if let genericHostRuleByPath = rules[appPath]?[genericHostKey], (!preferBlock || genericHostRuleByPath.action == Consts.verdictBlock) {
            return genericHostRuleByPath
        }
        if let specificHostRuleByPath = rules[appPath]?[specificHostKey], (!preferBlock || specificHostRuleByPath.action == Consts.verdictBlock) {
            return specificHostRuleByPath
        }
        
        return nil
    }

    private func getRuleByIp(_ appPath: String, _ bundleID: String, _ ip: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        let genericIpKey = "\(ip):\(Consts.any)"
        let specificIpKey = "\(ip):\(port)"
        
        if let genericIpRuleByBundleID = rules[bundleID]?[genericIpKey], (!preferBlock || genericIpRuleByBundleID.action == Consts.verdictBlock) {
            return genericIpRuleByBundleID
        }
        if let specificIpRuleByBundleID = rules[bundleID]?[specificIpKey], (!preferBlock || specificIpRuleByBundleID.action == Consts.verdictBlock) {
            return specificIpRuleByBundleID
        }
        
        if let genericIpRuleByPath = rules[appPath]?[genericIpKey], (!preferBlock || genericIpRuleByPath.action == Consts.verdictBlock) {
            return genericIpRuleByPath
        }
        if let specificIpRuleByPath = rules[appPath]?[specificIpKey], (!preferBlock || specificIpRuleByPath.action == Consts.verdictBlock) {
            return specificIpRuleByPath
        }
        
        return nil
    }
}
