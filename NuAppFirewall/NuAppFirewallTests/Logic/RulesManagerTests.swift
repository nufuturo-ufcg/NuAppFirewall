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

    var rulesManager: RulesManager!

    override func setUp() {
        super.setUp()
        rulesManager = RulesManager()
    }

    override func tearDown() {
        rulesManager = nil
        super.tearDown()
    }

    // Test case: Validate that all possible combinations of rules are correctly initialized with accurate properties.
    func testRuleInitialization() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
            
        for ruleData in ruleDataArray {
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertEqual(rule.ruleID, ruleData.ruleID, "Mismatch in ruleID for \(testInfo).")
        }
    }
    
    // Test case: Ensure all possible rule combinations can be added successfully and validate their addition.
    func testAddRule() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertNoThrow(try rulesManager.addRule(rule), "Failed to add rule for \(testInfo).")
            
            let fetchedRule = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)
            XCTAssertNotNil(fetchedRule, "Rule was not retrieved for \(testInfo).")
            XCTAssertEqual(fetchedRule, rule, "Mismatch for \(testInfo). Retrieved: \(String(describing: fetchedRule)), Expected: \(String(describing: rule)).")
        }
    }
    
    // Test case: Ensure that attempting to add duplicate rules results in an error.
    func testAddDuplicateRule() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertNoThrow(try rulesManager.addRule(rule), "Failed to add rule for \(testInfo).")
            
            XCTAssertThrowsError(try rulesManager.addRule(rule), "Expected error when adding duplicate rule for \(testInfo).") { error in
                if case RulesManagerError.ruleAlreadyExists = error {
                    LogManager.logManager.log("Correctly identified rule duplication for \(testInfo)", level: .debug)
                } else {
                    XCTFail("Unexpected error for \(testInfo): \(error)")
                }
            }
        }
    }
    
    // Test case: Ensure all possible rule combinations can be retrieved successfully after being added.
    func testRetrievalRule() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertNoThrow(try rulesManager.addRule(rule), "Failed to add rule for \(testInfo).")
            
            let fetchedRule = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)
            XCTAssertNotNil(fetchedRule, "Rule was not retrieved for \(testInfo).")
            XCTAssertEqual(fetchedRule, rule, "Mismatch for \(testInfo). Retrieved: \(String(describing: fetchedRule)), Expected: \(String(describing: rule)).")
        }
    }
    
    // Test case: Ensure all possible rule combinations can be removed successfully and validate their absence post-removal.
    func testRemoveRule() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertNoThrow(try rulesManager.addRule(rule), "Failed to add rule for \(testInfo).")
            
            let removedRule = rulesManager.removeRule(app: ruleData.app, destination: ruleData.destination)
            XCTAssertNotNil(removedRule, "Failed to remove rule for \(testInfo).")
            
            let fetchedRuleAfterRemoval = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)
            XCTAssertNil(fetchedRuleAfterRemoval, "Rule still exists after removal for \(testInfo).")
        }
    }
    
    // Test case: Validate that block rules take precedence over allow rules when multiple rules share the same app identification (e.g., bundle ID, app path, or subpath).
    func testAddRuleWithSameParamsDifferentActions() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            let testInfo = "RuleID  \(ruleData.ruleID)"
            
            guard let rule1 = TestDataFactory.createRule(action: Consts.verdictAllow, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create first rule for \(testInfo).")
                continue
            }

            XCTAssertNoThrow(try rulesManager.addRule(rule1), "Failed to add the first rule for \(testInfo).")

            guard let rule2 = TestDataFactory.createRule(action: Consts.verdictBlock, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create second rule for \(testInfo).")
                continue
            }

            XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should not allow adding duplicate rule with different action for \(testInfo).")

            let fetchedRule = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)
            XCTAssertNotNil(fetchedRule, "Rule should be retrieved for \(testInfo).")
            XCTAssertEqual(fetchedRule, rule1, "The fetched rule should match the first rule for \(testInfo).")
            XCTAssertNotEqual(fetchedRule, rule2, "The fetched rule should not match the second rule with different action for \(testInfo).")
        }
    }
    
    // Test case: Validate the precedence of the block rule over others allow rules with same app identification
    func testBlockRulePrecedenceWithAllowRules() {
        let bundleRules = TestDataFactory.generateRuleData(apps: [TestConstants.bundleID])
        let pathRules = TestDataFactory.generateRuleData(apps: [TestConstants.appPath])
        let subpathRules = TestDataFactory.generateRuleData(apps: [TestConstants.appSubpath])
        
        validateBlockRulePrecedence(blockRules: bundleRules.filter { $0.action == Consts.verdictBlock },
                                    allowRules: bundleRules.filter { $0.action == Consts.verdictAllow })

        validateBlockRulePrecedence(blockRules: pathRules.filter { $0.action == Consts.verdictBlock },
                                    allowRules: pathRules.filter { $0.action == Consts.verdictAllow })

        validateBlockRulePrecedence(blockRules: subpathRules.filter { $0.action == Consts.verdictBlock },
                                    allowRules: subpathRules.filter { $0.action == Consts.verdictAllow })
    }

    private func validateBlockRulePrecedence(blockRules: [RuleData], allowRules: [RuleData]) {
        for blockRuleData in blockRules {
            rulesManager = RulesManager()

            for allowRuleData in allowRules {
                if allowRuleData.app == blockRuleData.app && allowRuleData.destination == blockRuleData.destination { continue }

                guard let allowRule = TestDataFactory.createRule(action: allowRuleData.action, app: allowRuleData.app, endpoint: allowRuleData.endpoint, port: allowRuleData.port
                ) else {
                    XCTFail("Failed to create allow rule: \(allowRuleData.ruleID)")
                    continue
                }

                XCTAssertNoThrow(try rulesManager.addRule(allowRule), "Failed to add allow rule: \(allowRuleData.ruleID)")
            }

            guard let blockRule = TestDataFactory.createRule(action: blockRuleData.action, app: blockRuleData.app, endpoint: blockRuleData.endpoint, port: blockRuleData.port
            ) else {
                XCTFail("Failed to create block rule: \(blockRuleData.ruleID)")
                continue
            }

            XCTAssertNoThrow(try rulesManager.addRule(blockRule), "Failed to add block rule: \(blockRuleData.ruleID)")

            let fetchedRule = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)

            XCTAssertNotNil(fetchedRule, "Failed to fetch rule for \(blockRuleData.ruleID)")
            XCTAssertEqual(fetchedRule, blockRule, "Block rule did not take precedence over allow rules: \(blockRuleData.ruleID)")
        }
    }
    
    // Test case: Ensure that removing a non-existing rule returns nil
    func testRemoveNonExistingRule() {
        let app = TestConstants.appPath
        let destination = "NonExistingDestination"
        
        let removedRule = rulesManager.removeRule(app: app, destination: destination)
        
        XCTAssertNil(removedRule, "Removing a non-existing rule should return nil.")
    }
    
    // Test case: Ensure that after removing one rule, the remaining rules are preserved
    func testRemoveRuleWithRemainingRules() {
        guard let rule1 = TestDataFactory.createRule(action: TestConstants.actionAllow, app: TestConstants.appPath, endpoint: TestConstants.ip, port: TestConstants.port),
              let rule2 = TestDataFactory.createRule(action: TestConstants.actionAllow, app: TestConstants.appPath, endpoint: TestConstants.host, port: TestConstants.port) else {
            XCTFail("Failed to create rules for the test case.")
            return
        }
        
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Failed to add rule1.")
        XCTAssertNoThrow(try rulesManager.addRule(rule2), "Failed to add rule2.")
        
        let removedRule = rulesManager.removeRule(app: rule1.application, destination: rule1.destination)
        
        XCTAssertNotNil(removedRule, "Rule should be removed successfully.")
        XCTAssertEqual(removedRule?.destination, rule1.destination, "The removed rule should match the expected destination.")
        
        let remainingRule = rulesManager.rules[TestConstants.appPath]?[rule2.destination]
        XCTAssertNotNil(remainingRule, "The remaining rule should still exist.")
        XCTAssertEqual(remainingRule?.destination, rule2.destination, "The remaining rule should match the expected destination.")
    }
    
    // Test case: Attempt to add a rule with nil value or invalid rule
    func testAddInvalidRule() {
        do {
            try rulesManager.addRule(nil)
            XCTFail("Adding nil rule should throw an error.")
        } catch RulesManagerError.invalidRule {
            // Expected error
        } catch {
            XCTFail("Unexpected error thrown.")
        }
    }
}
