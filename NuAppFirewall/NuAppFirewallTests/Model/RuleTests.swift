/*
     File: RuleTests.swift
     Project: App Firewall (nufuturo.nuappfirewall)
     Description: Unit test class that uses XCTest to validate
         the behavior of the Rule class.

     Created by com.nufuturo.nuappfirewall
*/

import XCTest
@testable import NuAppFirewall

class RuleTests: XCTestCase {
    
    let ruleID = "AppPath/Test"
    let action = Consts.verdictAllow
    let appLocation = "/Applications/MyApp"
    let endpoint = "www.teste.com"
    let port = Consts.any
    
    override func setUpWithError() throws {
        super.setUp()
    }
    
    override func tearDownWithError()throws {
        super.tearDown()
    }
    
    // Test case: initializes a rule
    func testRuleInitialization() {
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: endpoint, port: port)

        XCTAssertNotNil(rule, "The rule must be created")
        XCTAssertEqual(rule?.ruleID, ruleID, "The ruleID must be initialized correctly.")
        XCTAssertEqual(rule?.action, action, "The action must be initialized correctly.")
        XCTAssertEqual(rule?.appLocation, appLocation, "The application location must be initialized correctly.")
        XCTAssertEqual(rule?.endpoint, endpoint, "Endpoint must be initialized correctly.")
        XCTAssertEqual(rule?.port, port, "The port must be initialized correctly.")
        XCTAssertEqual(rule?.destination, "\(endpoint):\(port)", "The destination must be initialized correctly.")
    }
    
    // Test case: Verify description method to ensure the output is formatted correctly
    func testRuleDescription() throws {
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: endpoint, port: port)
        let description = rule?.description()
        let expectedDescription = """
        ruleID: \(ruleID)
        Action: \(action)
        Application Location: \(appLocation)
        Endpoint: \(endpoint)
        Destination: \(endpoint):\(port)
        Port: \(port)
        """
        XCTAssertEqual(description, expectedDescription, "The descriptions should match")
    }
    
    // Test the equals method (Equatable implementation)
    func testRuleEquality() throws {
        let rule1 = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: endpoint, port: port)
        let rule2 = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: endpoint, port: port)
        let rule3 = Rule(ruleID: "/Applications/DifferentApp.app", action: action, appLocation: "/Applications/DifferentApp.app", endpoint: "10.0.0.1", port: "443")
        
        // Ensure rule1 and rule2 are equal
        XCTAssertEqual(rule1, rule2, "Rules with the same properties should be considered equal")
        
        // Ensure rule1 and rule3 are not equal
        XCTAssertNotEqual(rule1, rule3, "Rules with different properties should not be considered equal")
    }
}
