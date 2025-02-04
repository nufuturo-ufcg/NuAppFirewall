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
    let rulesLoader = RulesLoader()
    
    func loadRules(fileName: String, fileType: FileType) {
        self.rules = rulesLoader.loadRules(fileName: fileName, fileType: fileType)
        self.applications = Set(rules.keys)
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
        var matchedRules: [Rule] = []
        
        matchedRules.append(contentsOf: findRules(app: bundleID, url: url, host: host, ip: ip, port: port, fallbackToSubpath: false))
        let bundleRule = selectRule(from: matchedRules, url, host, ip, port, preferBlock: true)
        guard bundleRule == nil else {
            return bundleRule
        }
        
        matchedRules.append(contentsOf: findRules(app: appPath, url: url, host: host, ip: ip, port: port))
        let pathRule = selectRule(from: matchedRules, url, host, ip, port, preferBlock: true)
        
        return pathRule
    }
    
    private func findRules(app: String, url: String, host: String, ip: String, port: String, fallbackToSubpath: Bool = true) -> [Rule] {
        guard applications.contains(app) else {
            LogManager.logManager.log("Application not found: \(app)", level: .debug)
                
            if fallbackToSubpath {
                LogManager.logManager.log("Falling back to subpath search: \(app)", level: .debug)
                let subpathRules = getRulesBySubpath(app)
                    
                for rule in subpathRules {
                    let newRule = createRule(action: rule.action, app: app, endpoint: rule.endpoint, port: rule.port)
                    handleRuleAddition(newRule!)
                }
                    
                return subpathRules
            }
                
            return []
        }
        
        var specificRules: [Rule] = []
        
        if let generalRule = getGeneralRule(app) {
            specificRules.append(generalRule)
        }
        
        specificRules.append(contentsOf: getRulesByUrl(app, url, port))
        specificRules.append(contentsOf: getRulesByHost(app, host, port))
        specificRules.append(contentsOf: getRulesByIp(app, ip, port))

        return specificRules
    }
    
    private func selectRule(from rules: [Rule], _ url: String, _ host: String, _ ip: String, _ port: String, preferBlock: Bool = true) -> Rule? {
        var rulesByDestination: [String: [Rule]] = [:]
        
        for rule in rules {
            rulesByDestination[rule.destination, default: []].append(rule)
        }
        
        let destinations = [
            "\(Consts.any):\(Consts.any)",
            "\(url):\(Consts.any)",
            "\(url):\(port)",
            "\(host):\(Consts.any)",
            "\(host):\(port)",
            "\(ip):\(Consts.any)",
            "\(ip):\(port)"
        ]
        
        for destination in destinations {
            if let rules = rulesByDestination[destination] {
                if preferBlock {
                    if let blockRule = rules.first(where: { $0.action == Consts.verdictBlock }) {
                        return blockRule
                    }
                }
            }
        }

        for destination in destinations {
            if let rules = rulesByDestination[destination] {
                return rules.first
            }
        }

        return nil
    }
    
    private func getRulesBySubpath(_ appPath: String) -> [Rule] {
        var matchedRules: [Rule] = []

        for (path, destinations) in rules {
            guard appPath.range(of: path) != nil else { continue }

            for (_, rule) in destinations {
                matchedRules.append(rule)
            }
        }

        return matchedRules
    }
    
    private func getGeneralRule(_ app: String) -> Rule? {
        if let generalRule = rules[app]?["\(Consts.any):\(Consts.any)"] {
            return generalRule
        }
        
        return nil
    }
    
    private func getRulesByUrl(_ app: String, _ url: String, _ port: String) -> [Rule] {
        return getSpecificOrGenericRule(app, url, port)
    }

    private func getRulesByHost(_ app: String, _ host: String, _ port: String) -> [Rule] {
        return getSpecificOrGenericRule(app, host, port)
    }

    private func getRulesByIp(_ app: String, _ ip: String, _ port: String) -> [Rule] {
        return getSpecificOrGenericRule(app, ip, port)
    }
    
    private func getSpecificOrGenericRule(_ app: String, _ keyBase: String, _ port: String) -> [Rule] {
        var matchedRules: [Rule] = []
        
        let genericKey = "\(keyBase):\(Consts.any)"
        if let genericRule = rules[app]?[genericKey] {
            matchedRules.append(genericRule)
        }
        
        let specificKey = "\(keyBase):\(port)"
        if let specificRule = rules[app]?[specificKey] {
            matchedRules.append(specificRule)
        }
        
        return matchedRules
    }
}
