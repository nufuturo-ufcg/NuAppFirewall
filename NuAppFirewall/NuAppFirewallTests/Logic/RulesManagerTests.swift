/*  
    File: RulesManagerTests.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: Unit test class that uses XCTest to validate
        the behavior of the RulesManager class.

    Created by com.nufuturo.nuappfirewall
*/

import XCTest
@testable import NuAppFirewall

class RulesManagerTests: XCTestCase {

    var manager: RulesManager!
    var initialEndpoints: Set<String>!

    override func setUp() {
        super.setUp()
        manager = RulesManager()

        let rule1 = Rule(
            ruleID: "/Applications/Test.app",
            action: "allow",
            appLocation: "/Applications/Test.app",
            endpoints: ["192.168.1.1"],
            direction: "outgoing"
        )

        // Ensuring no nil values are passed to `addRule`
        XCTAssertNoThrow(try manager.addRule(rule1))

        initialEndpoints = ["192.168.1.1", "192.168.1.2"]

        let rule2 = Rule(
            ruleID: "/Applications/Test2.app",
            action: "allow",
            appLocation: "/Applications/Test2.app",
            endpoints: initialEndpoints,
            direction: "outgoing"
        )

        XCTAssertNoThrow(try manager.addRule(rule2))
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // Test case: Rule Initialization
    func testRuleInitialization() {
        let ruleID = "/Applications/MyApp"
        let action = "allow"
        let appLocation = "/Applications/MyApp"
        let endpoints: Set<String> = ["192.168.1.1", "192.168.1.2"]
        let direction = "outbound"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoints: endpoints, direction: direction)

        XCTAssertNotNil(rule, "The rule must be created with non-empty endpoints.")
        XCTAssertEqual(rule?.ruleID, ruleID, "The ruleID must be initialized correctly.")
        XCTAssertEqual(rule?.action, action, "The action must be initialized correctly.")
        XCTAssertEqual(rule?.appLocation, appLocation, "The application location must be initialized correctly.")
        XCTAssertEqual(rule?.endpoints, endpoints, "Endpoints must be initialized correctly.")
        XCTAssertEqual(rule?.direction, direction, "The direction must be initialized correctly.")
    }

    // Test case: Add a rule
    func testAddRule() {
        let endpoints: Set = ["e673.dsce9.akamaiedge.net", "23.41.188.23"]

        let rule3 = Rule(
            ruleID: "/Library/Apple/System/Library/CoreServices/SafariSupport.bundle/Contents/MacOS/PasswordBreachAgent",
            action: "allow",
            appLocation: "/Library/Apple/System/Library/CoreServices/SafariSupport.bundle/Contents/MacOS/PasswordBreachAgent",
            endpoints: endpoints,
            direction: "outgoing"
        )

        XCTAssertNoThrow(try manager.addRule(rule3))
        let fetchedRule = manager.getRule(byID: rule3!.ruleID)
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved.")
        XCTAssertEqual(fetchedRule?.ruleID, rule3?.ruleID, "The ruleID should match.")
        XCTAssertEqual(fetchedRule?.action, rule3?.action, "The action should match.")
    }

    // Test case: Add another rule with different attributes
    func testAddAnotherRule() {
        let endpoints: Set = ["142.251.16.94", "sync.intentiq.com", "208.80.154.224"]

        let rule2 = Rule(
            ruleID: "/System/Volumes/Preboot/Cryptexes/App/System/Library/StagedFrameworks/Safari/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper",
            action: "allow",
            appLocation: "/System/Volumes/Preboot/Cryptexes/App/System/Library/StagedFrameworks/Safari/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper",
            endpoints: endpoints,
            direction: "outgoing"
        )

        XCTAssertNoThrow(try manager.addRule(rule2))
        let fetchedRule = manager.getRule(byID: rule2!.ruleID)
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved.")
        XCTAssertEqual(fetchedRule?.ruleID, rule2!.ruleID, "The ruleID should match.")
        XCTAssertEqual(fetchedRule?.action, rule2!.action, "The action should match.")
    }

    // Test case: Attempt to retrieve a rule that doesn't exist
    func testRetrieveNonExistentRule() {
        let nonExistentRuleID = "non-existent-id"
        let fetchedRule = manager.getRule(byID: nonExistentRuleID)
        XCTAssertNil(fetchedRule, "No rule should be found with a non-existent ID.")
    }

    // Test case: Remove an existing rule
    func testRemoveExistingRule() {
        let ruleID = "/Applications/Test.app"

        let removedRule = manager.removeRule(byID: ruleID)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil.")

        let fetchedRuleAfterRemoval = manager.getRule(byID: ruleID)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal.")
    }

    // Test case: Try to remove a rule that has already been removed
    func testRemoveAlreadyRemovedRule() {
        let ruleID = "/Applications/Test.app"

        let firstRemoval = manager.removeRule(byID: ruleID)
        XCTAssertNotNil(firstRemoval, "The first removal should return the removed rule.")

        let secondRemoval = manager.removeRule(byID: ruleID)
        XCTAssertNil(secondRemoval, "The second removal should return nil, as the rule has already been removed.")
    }

    // Test case: Add a rule with the same ruleID and validate destinations update
    func testAddRuleWithSameIDUpdatesDestinations() {
        let newEndpoints: Set = ["192.168.1.3"]

        let updatedRule = Rule(
            ruleID: "/Applications/Test2.app",
            action: "allow",
            appLocation: "/Applications/Test2.app",
            endpoints: newEndpoints,
            direction: "outgoing"
        )

        XCTAssertNoThrow(try manager.addRule(updatedRule))

        let fetchedRule = manager.getRule(byID: "/Applications/Test2.app")
        XCTAssertNotNil(fetchedRule, "The rule must be retrieved.")
        XCTAssertEqual(fetchedRule?.endpoints, initialEndpoints.union(newEndpoints), "Destinations must be updated to include the new entries.")
    }

    // Test case: Attempt to add a rule with nil value or invalid rule
    func testAddInvalidRule() {
        do {
            try manager.addRule(nil)
            XCTFail("Adding nil rule should throw an error.")
        } catch RulesManagerError.invalidRule {
            // Expected error
        } catch {
            XCTFail("Unexpected error thrown.")
        }
    }
}
