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
    var applications: Set<String> = []
    let dataConverter = DataConverter()
    
    func loadRules(fileName: String, fileType: FileType) {
        guard let dictionary = dataConverter.readData(from: fileName, ofType: fileType) else {
            LogManager.logManager.log("Failed to read data from file: \(fileName)", level: .error)
            return
        }
        
        rules.removeAll()
        applications.removeAll()
        
        for (path, rulesArray) in dictionary {
            guard let rulesArray = rulesArray as? [[String: Any]] else { continue }
            
            for ruleData in rulesArray {
                guard let action = ruleData["action"] as? String,
                      let destinations = ruleData["destinations"] as? [[String]],
                      let identifier = ruleData["identifier"] as? String else { continue }
                
                for destination in destinations {
                    let endpoint = destination[0]
                    let port = destination[1]
                    let destinationKey = "\(endpoint):\(port)"
                    let ruleIDForPath = "\(path)-\(action)-\(destinationKey)"
                    
                    if let ruleForPath = Rule(ruleID: ruleIDForPath, action: action, app: path, endpoint: endpoint, port: port) {
                        handleRuleAddition(ruleForPath, ruleIDForPath, path)
                    }

                    if identifier != "unknown" {
                        let ruleIDForBundle = "\(identifier)-\(action)-\(destinationKey)"
                        if let ruleForBundle = Rule(ruleID: ruleIDForBundle, action: action, app: identifier, endpoint: endpoint, port: port) {
                            handleRuleAddition(ruleForBundle, ruleIDForBundle, identifier)
                        }
                    }
                }
            }
        }
    }
    
    private func handleRuleAddition(_ rule: Rule, _ ruleID: String, _ application: String) {
        do {
            try addRule(rule)
            applications.insert(application)
            LogManager.logManager.log("Added new rule with ID: \(ruleID)", level: .debug)
        } catch RulesManagerError.ruleAlreadyExists {
            LogManager.logManager.log("Rule already exists with ID: \(ruleID)", level: .debug)
        } catch {
            LogManager.logManager.log("Failed to add rule with ID: \(ruleID): \(error)", level: .debug)
        }
    }
    
    func removeRule(app: String, destination: String) -> Rule? {
        guard var appRules = rules[app], let removedRule = appRules.removeValue(forKey: destination) else {
            return nil
        }
        
        if appRules.isEmpty {
            rules.removeValue(forKey: app)
            applications.remove(app)
        } else {
            rules[app] = appRules
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
        applications.insert(rule.application)
    }
    
    func getRule(bundleID: String, appPath: String, url: String, host: String, ip: String, port: String) -> Rule? {
        if let rule = findRule(app: appPath, url: url, host: host, ip: ip, port: port, preferBlock: true) {
            return rule
        }
        
        if let rule = findRule(app: bundleID, url: url, host: host, ip: ip, port: port, preferBlock: true) {
            return rule
        }
        
        return nil
    }
    
    private func findRule(app: String, url: String, host: String, ip: String, port: String, preferBlock: Bool = false) -> Rule? {
        guard applications.contains(app) else {
            LogManager.logManager.log("Application not found, falling back to subpath search: \(app)", level: .debug)
            return getRuleBySubstring(app, "\(Consts.any):\(Consts.any)")
        }
        
        return getGeneralRule(app, preferBlock: preferBlock)
            ?? getRuleByUrl(app, url, port, preferBlock: preferBlock)
            ?? getRuleByHost(app, host, port, preferBlock: preferBlock)
            ?? getRuleByIp(app, ip, port, preferBlock: preferBlock)
    }
    
    private func getRuleBySubstring(_ appPath: String, _ appDestination: String) -> Rule? {
        var allowRule: Rule? = nil

        for (path, destinations) in rules {
            guard appPath.range(of: path) != nil else { continue }

            for (destination, rule) in destinations {
                guard appDestination == destination else { continue }

                if rule.action == Consts.verdictAllow && allowRule == nil {
                    allowRule = rule
                } else if rule.action == Consts.verdictBlock {
                    let ruleID = "\(appPath)-\(rule.action)-\(destination)"
                    let newRule = Rule(ruleID: ruleID, action: rule.action, app: appPath, endpoint: rule.endpoint, port: rule.port)
                    handleRuleAddition(newRule!, ruleID, path)
                    return rule
                }
            }
        }

        return allowRule
    }
    
    private func getGeneralRule(_ app: String, preferBlock: Bool = false) -> Rule? {
        if let generalRule = rules[app]?["\(Consts.any):\(Consts.any)"], (!preferBlock || generalRule.action == Consts.verdictBlock) {
            return generalRule
        }
        return nil
    }
    
    private func getRuleByUrl(_ app: String, _ url: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(app, keyBase: url, port: port, preferBlock: preferBlock)
    }

    private func getRuleByHost(_ app: String, _ host: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(app, keyBase: host, port: port, preferBlock: preferBlock)
    }

    private func getRuleByIp(_ app: String, _ ip: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        return getSpecificOrGenericRule(app, keyBase: ip, port: port, preferBlock: preferBlock)
    }
    
    private func getSpecificOrGenericRule(_ app: String, keyBase: String, port: String, preferBlock: Bool) -> Rule? {
        let genericKey = "\(keyBase):\(Consts.any)"
        if let genericRule = rules[app]?[genericKey], (!preferBlock || genericRule.action == Consts.verdictBlock) {
            return genericRule
        }
        
        let specificKey = "\(keyBase):\(port)"
        if let specificRule = rules[app]?[specificKey], (!preferBlock || specificRule.action == Consts.verdictBlock) {
            return specificRule
        }
        
        return nil
    }
}
