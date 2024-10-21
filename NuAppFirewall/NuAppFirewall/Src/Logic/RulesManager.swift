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
    
    init() {
        //place-holder
        let rule1 = Rule(
            ruleID: "1", //mock-id
            action: "0",
            appLocation: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend",
            endpoints: ["wikipedia.org", "youtube.com"],
            direction: "*"
        )
        
        do {
            try addRule(rule1)
        } catch {}
    }
    
    func addRule(_ rule: Rule?) throws {
        guard let rule = rule else {
            throw RulesManagerError.invalidRule
        }
        
        if let existingRule = rules[rule.ruleID] {
            // Update the existing rule's destinations set
            existingRule.endpoints.formUnion(rule.endpoints)
            rules[rule.ruleID] = existingRule
        } else {
            // Add the new rule if it does not exist
            rules[rule.ruleID] = rule
        }
    }
    
    func removeRule(byID ruleID: String) -> Rule? {
        return rules.removeValue(forKey: ruleID)
    }
    
    func getRule(byID ruleID: String) -> Rule? {
        return rules[ruleID]
    }
    
    func getRules(byApp applicationPath: String) -> [Rule] {
        return rules.values.filter { $0.appLocation == applicationPath }
    }
}
