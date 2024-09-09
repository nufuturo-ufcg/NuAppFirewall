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
    var destinations: Set<String>
    var direction: String

    init?(ruleID: String, action: String, appLocation: String, destinations: Set<String>, direction: String) {
        guard !destinations.isEmpty else {
            return nil
        }

        self.ruleID = ruleID
        self.action = action
        self.appLocation = appLocation
        self.destinations = destinations
        self.direction = direction
    }

    func description() -> String {
        return """
        ruleID: \(ruleID)
        Action: \(action)
        Application Location: \(appLocation)
        Destinations: \(destinations.sorted().joined(separator: ", "))
        Direction: \(direction)
        """
    }

    // Implementing the Equatable protocol
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.ruleID == rhs.ruleID &&
               lhs.action == rhs.action &&
               lhs.appLocation == rhs.appLocation &&
               lhs.destinations == rhs.destinations &&
               lhs.direction == rhs.direction
    }
}
