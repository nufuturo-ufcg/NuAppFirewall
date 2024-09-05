/*  
    File: Rule.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: This class manages a collection of `Rule` objects
        using a dictionary with rule IDs as keys. 

    Created by com.nufuturo.nuappfirewall
*/

import Foundation

class RulesManager {
    private var rules: [String: Rule] = [:]
    
    func addRule(_ rule: Rule) {
        if var existingRule = rules[rule.ruleID] {
            // Update the existing rule's destinations set
            existingRule.destinations.formUnion(rule.destinations)
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
}
