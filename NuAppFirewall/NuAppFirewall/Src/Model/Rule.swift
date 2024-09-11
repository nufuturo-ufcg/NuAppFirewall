/*  
    File: Rule.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: This class defines a `Rule` object with properties 
        to represent a set of criteria or conditions.

    Created by com.nufuturo.nuappfirewall
*/

import Foundation

class Rule: Equatable {
    var ruleID: String
    var action: String
    var appLocation: String
    var endpoints: Set<String>
    var direction: String

    init?(ruleID: String, action: String, appLocation: String, endpoints: Set<String>, direction: String) {
        guard !endpoints.isEmpty else {
            return nil
        }

        self.ruleID = ruleID
        self.action = action
        self.appLocation = appLocation
        self.endpoints = endpoints
        self.direction = direction
    }

    func description() -> String {
        return """
        ruleID: \(ruleID)
        Action: \(action)
        Application Location: \(appLocation)
        Destinations: \(endpoints.sorted().joined(separator: ", "))
        Direction: \(direction)
        """
    }

    // Implementing the Equatable protocol
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.ruleID == rhs.ruleID &&
               lhs.action == rhs.action &&
               lhs.appLocation == rhs.appLocation &&
               lhs.endpoints == rhs.endpoints &&
               lhs.direction == rhs.direction
    }
}
