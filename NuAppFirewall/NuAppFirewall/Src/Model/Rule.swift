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
    var endpoint: String
    var port: String
    var destination: String

    init?(ruleID: String, action: String, appLocation: String, endpoint: String, port: String) {
        guard !endpoint.isEmpty else {
            return nil
        }

        self.ruleID = ruleID
        self.action = action
        self.appLocation = appLocation
        self.endpoint = endpoint
        self.port = port
        self.destination = "\(endpoint):\(port)"
    }

    func description() -> String {
        return """
        ruleID: \(ruleID)
        Action: \(action)
        Application Location: \(appLocation)
        Endpoint: \(endpoint)
        Destination: \(destination)
        Port: \(port)
        """
    }

    // Implementing the Equatable protocol
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.ruleID == rhs.ruleID &&
               lhs.action == rhs.action &&
               lhs.appLocation == rhs.appLocation &&
               lhs.endpoint == rhs.endpoint &&
               lhs.destination == rhs.destination &&
               lhs.port == rhs.port
    }
}
