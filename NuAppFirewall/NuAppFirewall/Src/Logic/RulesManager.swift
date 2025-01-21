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
    
    func loadRules(fileName: String, fileType: FileType) {

        guard let dictionary = loadData(fileName: fileName, fileType: fileType) else {
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
                    
                    if let ruleForPath = createRule(action: action, app: path, endpoint: endpoint, port: port) {
                        handleRuleAddition(ruleForPath)
                    }

                    if identifier != "unknown" {
                        if let ruleForBundle = createRule(action: action, app: identifier, endpoint: endpoint, port: port) {
                            handleRuleAddition(ruleForBundle)
                        }
                    }
                }
            }
        }
    }
    
    private func createRule(action: String, app: String, endpoint: String, port: String) -> Rule? {
        let destination = "\(endpoint):\(port)"
        let ruleID = "\(app)-\(action)-\(destination)"
        
        return Rule(ruleID: ruleID, action: action, app: app, endpoint: endpoint, port: port) ?? nil
    }
    
    private func handleRuleAddition(_ rule: Rule) {
        do {
            try addRule(rule)
            applications.insert(rule.application)
            LogManager.logManager.log("Added new rule with ID: \(rule.ruleID)", level: .debug)
        } catch RulesManagerError.ruleAlreadyExists {
            LogManager.logManager.log("Rule already exists with ID: \(rule.ruleID)", level: .debug)
        } catch {
            LogManager.logManager.log("Failed to add rule with ID: \(rule.ruleID): \(error)", level: .debug)
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
        var matchedRules: Set<Rule> = []
        
        matchedRules.formUnion(findRules(app: bundleID, url: url, host: host, ip: ip, port: port))
        let bundleRule = selectRule(from: matchedRules, url, host, ip, port, preferBlock: true)
        guard bundleRule == nil else {
            return bundleRule
        }
        
        matchedRules.formUnion(findRules(app: appPath, url: url, host: host, ip: ip, port: port))
        let pathRule = selectRule(from: matchedRules, url, host, ip, port, preferBlock: true)
        
        return pathRule
    }
    
    private func findRules(app: String, url: String, host: String, ip: String, port: String) -> Set<Rule> {
        guard applications.contains(app) else {
            LogManager.logManager.log("Application not found, falling back to subpath search: \(app)", level: .debug)
            let subpathRules = getRulesBySubpath(app)
            
            for rule in subpathRules {
                let newRule = createRule(action: rule.action, app: app, endpoint: rule.endpoint, port: rule.port)
                handleRuleAddition(newRule!)
            }
            
            return subpathRules
        }
        
        var specificRules: Set<Rule> = []
        specificRules.formUnion(getGeneralRule(app))
        specificRules.formUnion(getRulesByUrl(app, url, port))
        specificRules.formUnion(getRulesByHost(app, host, port))
        specificRules.formUnion(getRulesByIp(app, ip, port))

        return specificRules
    }
    
    private func selectRule(from rules: Set<Rule>, _ url: String, _ host: String, _ ip: String, _ port: String, preferBlock: Bool = false) -> Rule? {
        var allowRules: Set<Rule> = []
        var blockRules: Set<Rule> = []

        for rule in rules {
            if rule.action == Consts.verdictBlock {
                blockRules.insert(rule)
            } else {
                allowRules.insert(rule)
            }
        }
        
        let destinations = ["\(url):\(port)", "\(url):\(Consts.any)", "\(host):\(port)", "\(host):\(Consts.any)", "\(ip):\(port)", "\(ip):\(Consts.any)", "\(Consts.any):\(Consts.any)"]

        if preferBlock {
            for rule in blockRules {
                if destinations.contains(rule.destination) { return rule }
            }
            
            for rule in allowRules {
                if destinations.contains(rule.destination) { return rule }
            }
        }
        
        for rule in rules {
            if destinations.contains(rule.destination) { return rule }
        }
        
        return nil
    }
    
    private func getRulesBySubpath(_ appPath: String) -> Set<Rule> {
        var matchedRules: Set<Rule> = []

        for (path, destinations) in rules {
            guard appPath.range(of: path) != nil else { continue }

            for (_, rule) in destinations {
                matchedRules.insert(rule)
            }
        }

        return matchedRules
    }
    
    private func getGeneralRule(_ app: String) -> Set<Rule> {
        if let generalRule = rules[app]?["\(Consts.any):\(Consts.any)"] {
            return [generalRule]
        }
        
        return []
    }
    
    private func getRulesByUrl(_ app: String, _ url: String, _ port: String) -> Set<Rule> {
        return getSpecificOrGenericRule(app, keyBase: url, port: port)
    }

    private func getRulesByHost(_ app: String, _ host: String, _ port: String) -> Set<Rule> {
        return getSpecificOrGenericRule(app, keyBase: host, port: port)
    }

    private func getRulesByIp(_ app: String, _ ip: String, _ port: String) -> Set<Rule> {
        return getSpecificOrGenericRule(app, keyBase: ip, port: port)
    }
    
    private func getSpecificOrGenericRule(_ app: String, keyBase: String, port: String) -> Set<Rule> {
        var matchedRules: Set<Rule> = []
        
        let genericKey = "\(keyBase):\(Consts.any)"
        if let genericRule = rules[app]?[genericKey] {
            matchedRules.insert(genericRule)
        }
        
        let specificKey = "\(keyBase):\(port)"
        if let specificRule = rules[app]?[specificKey] {
            matchedRules.insert(specificRule)
        }
        
        return matchedRules
    }
}
