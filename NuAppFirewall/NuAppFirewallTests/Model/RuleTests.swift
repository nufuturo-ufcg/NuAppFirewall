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
    
    override func setUpWithError() throws {
        super.setUp()
    }
    
    override func tearDownWithError()throws {
        super.tearDown()
    }
    
    // Tests the initialization of a Rule object with valid data
    func testRuleInitialization() throws {
        let ruleID = "/Applications/SampleApp.app"
        let action = "allow"
        let appLocation = "/Applications/SampleApp.app"
        let destinations: Set<String> = ["192.168.1.1", "192.168.1.2"]
        let direction = "outgoing"
        
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        XCTAssertNotNil(rule)
        XCTAssertEqual(rule?.ruleID, ruleID)
        XCTAssertEqual(rule?.action, action)
        XCTAssertEqual(rule?.appLocation, appLocation)
        XCTAssertEqual(rule?.destinations, destinations)
        XCTAssertEqual(rule?.direction, direction)
    }
    
    // Tests the description method to ensure the output is formatted correctly
    func testRuleDescription() throws {
        let ruleID = "/Applications/BlockedApp.app"
        let action = "allow"
        let appLocation = "/Applications/BlockedApp.app"
        let destinations: Set<String> = ["10.0.0.0", "10.0.0.1"]
        let direction = "outgoing"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        let description = rule?.description()
        
        let expectedDescription = """
        ruleID: /Applications/BlockedApp.app
        Action: allow
        Application Location: /Applications/BlockedApp.app
        Destinations: 10.0.0.0, 10.0.0.1
        Direction: outgoing
        """
        XCTAssertEqual(description, expectedDescription)
    }
    
    // Tests the creation of a Rule with an empty destinations set
    func testRuleWithEmptyDestinations() throws {
        let ruleID = "/Applications/SampleApp.app"
        let action = "allow"
        let appLocation = "/Applications/SampleApp.app"
        let destinations: Set<String> = []
        let direction = "outgoing"
        
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        XCTAssertNil(rule)
    }
    
    // Tests the creation of a Rule with non-empty destinations
    func testRuleWithNonEmptyDestinations() throws {
        let ruleID = "67890"
        let action = "allow"
        let appLocation = "/Applications/AnotherApp.app"
        let destinations: Set<String> = ["8.8.8.8"]
        let direction = "outgoing"
        
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        XCTAssertNotNil(rule)
        XCTAssertEqual(rule?.destinations, destinations)
    }
    
    // Test the equals method (Equatable implementation)
    func testRuleEquality() throws {
        // First rule instance
        let ruleID = "/Applications/TestApp.app"
        let action = "allow"
        let appLocation = "/Applications/TestApp.app"
        let destinations: Set<String> = ["192.168.1.1"]
        let direction = "outgoing"
        
        let rule1 = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        let rule2 = Rule(ruleID: ruleID, action: action, appLocation: appLocation, destinations: destinations, direction: direction)
        
        let rule3 = Rule(ruleID: "/Applications/DifferentApp.app", action: action, appLocation: "/Applications/DifferentApp.app", destinations: ["10.0.0.1"], direction: direction)
        
        // Ensure rule1 and rule2 are equal
        XCTAssertEqual(rule1, rule2, "Rules with the same properties should be considered equal")
        
        // Ensure rule1 and rule3 are not equal
        XCTAssertNotEqual(rule1, rule3, "Rules with different properties should not be considered equal")
    }
}
