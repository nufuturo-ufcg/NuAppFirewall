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
    var appIdentifiers: Set<String> = []
    let dataConverter = DataConverter()
    
    func loadRules(fileName: String, fileType: FileType) {
        guard let dictionary = dataConverter.readData(from: fileName, ofType: fileType) else {
            LogManager.logManager.log("Failed to read data from file: \(fileName)", level: .error)
            return
        }
        
        rules.removeAll()
        appIdentifiers.removeAll()
        
        for (path, rulesArray) in dictionary {
            guard let rulesArray = rulesArray as? [[String: Any]] else { continue }
            
            for ruleData in rulesArray {
                guard let action = ruleData["action"] as? String,
                      let destinations = ruleData["destinations"] as? [[String]],
                      let identifier = ruleData["identifier"] as? String else { continue }
                
                if identifier != "unknown" {
                    appIdentifiers.insert(identifier)
                }
                appIdentifiers.insert(path)
                
                for destination in destinations {
                    let endpoint = destination[0]
                    let port = destination[1]
                    let destinationKey = "\(endpoint):\(port)"
                    let ruleID = "\(path)-\(action)-\(destinationKey)"
                    
                    if let rule = Rule(ruleID: ruleID, action: action, appIdentifier: path, endpoint: endpoint, port: port) {
                        do {
                            try addRule(rule)
                            LogManager.logManager.log("Added rule with ID: \(ruleID) for path: \(path)", level: .debug)
                        } catch RulesManagerError.ruleAlreadyExists {
                            LogManager.logManager.log("Rule already exists with ID: \(ruleID)", level: .error)
                        } catch {
                            LogManager.logManager.log("Failed to add rule with ID: \(ruleID): \(error)", level: .error)
                        }
                    }

                    if identifier != "unknown" {
                        let ruleIDForBundle = "\(identifier)-\(action)-\(destinationKey)"
                        if let ruleForBundle = Rule(ruleID: ruleIDForBundle, action: action, appIdentifier: identifier, endpoint: endpoint, port: port) {
                            do {
                                try addRule(ruleForBundle)
                                LogManager.logManager.log("Added rule with ID: \(ruleIDForBundle) for bundleID: \(identifier)", level: .debug)
                            } catch RulesManagerError.ruleAlreadyExists {
                                LogManager.logManager.log("Rule already exists with ID: \(ruleIDForBundle)", level: .error)
                            } catch {
                                LogManager.logManager.log("Failed to add rule with ID: \(ruleIDForBundle): \(error)", level: .error)
                            }
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
        
        if appRules.isEmpty {
            rules.removeValue(forKey: appPath)
            appIdentifiers.remove(appPath)
        } else {
            rules[appPath] = appRules
        }
        return removedRule
    }
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else { throw RulesManagerError.invalidRule }
        let destination = "\(rule.endpoint):\(rule.port)"
        
        if rules[rule.application]?[destination] != nil {
            throw RulesManagerError.ruleAlreadyExists
        }
        
        rules[rule.application, default: [:]][destination] = rule
        appIdentifiers.insert(rule.application)
    }
    
    func getRule(bundleID: String, appPath: String, url: String, host: String, ip: String, port: String) -> Rule? {
        if let rule = findRule(appPath: bundleID, url: url, host: host, ip: ip, port: port, preferBlock: true) {
            return rule
        }
        
        if let rule = findRule(appPath: appPath, url: url, host: host, ip: ip, port: port, preferBlock: true) {
            return rule
        }
        
        return nil
    }
    
    private func findRule(appPath: String, url: String, host: String, ip: String, port: String, preferBlock: Bool = false) -> Rule? {
        guard appIdentifiers.contains(appPath) else {
            LogManager.logManager.log("App path not found, falling back to subpath search: \(appPath)", level: .debug)
            return getRuleBySubstring(appPath, "\(Consts.any):\(Consts.any)")
        }
        
        return getGeneralRule(appPath, preferBlock: preferBlock)
            ?? getRuleByUrl(appPath, url, port, preferBlock: preferBlock)
            ?? getRuleByHost(appPath, host, port, preferBlock: preferBlock)
            ?? getRuleByIp(appPath, ip, port, preferBlock: preferBlock)
    }
    
    private func getRuleBySubstring(_ appPath: String, _ appDestination: String) -> Rule? {
        var allowRule: Rule? = nil
        var blockRule: Rule? = nil

        for (path, destinations) in rules {
            if appPath.range(of: path) != nil {
                for (destination, rule) in destinations {
                    if appDestination == destination {
                        if rule.action == Consts.verdictAllow && allowRule == nil {
                            allowRule = rule
                        } else if rule.action == Consts.verdictBlock {
                            blockRule = rule
                            let ruleID = "\(appPath)-\(rule.action)-\(destination)"
                            let newRule = Rule(ruleID: ruleID, action: rule.action, appIdentifier: appPath, endpoint: rule.endpoint, port: rule.port)
                            do {
                                try addRule(newRule)
                                appIdentifiers.insert(appPath)
                                LogManager.logManager.log("Added new rule with ID: \(ruleID)", level: .debug)
                            } catch RulesManagerError.ruleAlreadyExists {
                                LogManager.logManager.log("Rule already exists with ID: \(ruleID)", level: .error)
                            } catch {
                                LogManager.logManager.log("Failed to add rule with ID: \(ruleID): \(error)", level: .error)
                            }
                            return blockRule
                        }
                    }
                }
            }
        }
        return allowRule
    }
    
    private func getGeneralRule(_ appPath: String, preferBlock: Bool = false) -> Rule? {
        if let generalRule = rules[appPath]?["\(Consts.any):\(Consts.any)"], (!preferBlock || generalRule.action == Consts.verdictBlock) {
            return generalRule
        }
        return nil
    }
    
    private func getRuleByUrl(_ appPath: String, _ url: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(appPath, keyBase: url, port: port, preferBlock: preferBlock)
    }

    private func getRuleByHost(_ appPath: String, _ host: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(appPath, keyBase: host, port: port, preferBlock: preferBlock)
    }

    private func getRuleByIp(_ appPath: String, _ ip: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(appPath, keyBase: ip, port: port, preferBlock: preferBlock)
    }
    
    private func getSpecificOrGenericRule(_ appPath: String, keyBase: String, port: String, preferBlock: Bool) -> Rule? {
        let genericKey = "\(keyBase):\(Consts.any)"
        if let genericRule = rules[appPath]?[genericKey], (!preferBlock || genericRule.action == Consts.verdictBlock) {
            return genericRule
        }
        
        let specificKey = "\(keyBase):\(port)"
        if let specificRule = rules[appPath]?[specificKey], (!preferBlock || specificRule.action == Consts.verdictBlock) {
            return specificRule
        }
        
        return nil
    }
}

