/*  
    File: Rule.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: Unit test class that uses XCTest to validate
        the behavior of the RulesManager class.

    Created by com.nufuturo.nuappfirewall
*/

import XCTest
@testable import NuAppFirewall

class RulesManagerTests: XCTestCase {

    var manager: RulesManager!

    override func setUp() {
        super.setUp()
        manager = RulesManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // Test case 1: Add a rule and retrieve it
    func testAddAndRetrieveRule() {
        let destinations: Set = ["e673.dsce9.akamaiedge.net", "23.41.188.23"]
        
        let rule1 = Rule(
            ruleID: "/Library/Apple/System/Library/CoreServices/SafariSupport.bundle/Contents/MacOS/PasswordBreachAgent",
            action: "allow",
            appLocation: "/Library/Apple/System/Library/CoreServices/SafariSupport.bundle/Contents/MacOS/PasswordBreachAgent",
            destinations: destinations,
            direction: "outgoing"
        )

        manager.addRule(rule1)
        let fetchedRule1 = manager.getRule(byID: rule1.ruleID)
        XCTAssertNotNil(fetchedRule1, "Rule should be retrieved")
        XCTAssertEqual(fetchedRule1?.ruleID, rule1.ruleID, "The ruleID should match")
        XCTAssertEqual(fetchedRule1?.action, rule1.action, "The action should match")
    }

    // Test case 2: Add another rule with different attributes
    func testAddAnotherRule() {
        let destinations: Set = ["142.251.16.94", "sync.intentiq.com", "208.80.154.224"]
        
        let rule2 = Rule(
            ruleID: "/System/Volumes/Preboot/Cryptexes/App/System/Library/StagedFrameworks/Safari/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper",
            action: "allow",
            appLocation: "/System/Volumes/Preboot/Cryptexes/App/System/Library/StagedFrameworks/Safari/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper",
            destinations: destinations,
            direction: "outgoing"
        )

        manager.addRule(rule2)
        let fetchedRule2 = manager.getRule(byID: rule2.ruleID)
        XCTAssertNotNil(fetchedRule2, "Rule should be retrieved")
        XCTAssertEqual(fetchedRule2?.ruleID, rule2.ruleID, "The ruleID should match")
        XCTAssertEqual(fetchedRule2?.action, rule2.action, "The action should match")
    }

    // Test case 3: Attempt to retrieve a rule that doesn't exist
    func testRetrieveNonExistentRule() {
        let nonExistentRuleID = "non-existent-id"
        let fetchedRule = manager.getRule(byID: nonExistentRuleID)
        XCTAssertNil(fetchedRule, "No rule should be found with a non-existent ID")
    }

    // Test case 4: Remove an existing rule
    func testRemoveExistingRule() {
        let rule = Rule(
            ruleID: "test-rule",
            action: "allow",
            appLocation: "/Applications/Test.app",
            destinations: ["192.168.1.1"],
            direction: "outgoing"
        )
        
        manager.addRule(rule)
        let removedRule = manager.removeRule(byID: rule.ruleID)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil")
        
        let fetchedRuleAfterRemoval = manager.getRule(byID: rule.ruleID)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal")
    }

    // Test case 5: Try to remove a rule that has already been removed
    func testRemoveAlreadyRemovedRule() {
        let rule = Rule(
            ruleID: "test-rule",
            action: "allow",
            appLocation: "/Applications/Test.app",
            destinations: ["192.168.1.1"],
            direction: "outgoing"
        )
        
        manager.addRule(rule)
        let firstRemoval = manager.removeRule(byID: rule.ruleID)
        XCTAssertNotNil(firstRemoval, "The first removal should return the removed rule")
        
        let secondRemoval = manager.removeRule(byID: rule.ruleID)
        XCTAssertNil(secondRemoval, "The second removal should return nil, as the rule has already been removed.")
    }

    // Test case 6: Add a rule with the same ruleID and validate destinations update
    func testAddRuleWithSameIDUpdatesDestinations() {
        let initialDestinations: Set = ["192.168.1.1", "192.168.1.2"]
        let newDestinations: Set = ["192.168.1.3"]

        let initialRule = Rule(
            ruleID: "test-rule",
            action: "allow",
            appLocation: "/Applications/Test.app",
            destinations: initialDestinations,
            direction: "outgoing"
        )

        manager.addRule(initialRule)
        
        let updatedRule = Rule(
            ruleID: "test-rule",
            action: "allow",
            appLocation: "/Applications/Test.app",
            destinations: newDestinations,
            direction: "outgoing"
        )

        manager.addRule(updatedRule)

        let fetchedRule = manager.getRule(byID: "test-rule")
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved")
        XCTAssertEqual(fetchedRule?.destinations, initialDestinations.union(newDestinations), "The destinations should be updated to include the new entries")
    }
}
