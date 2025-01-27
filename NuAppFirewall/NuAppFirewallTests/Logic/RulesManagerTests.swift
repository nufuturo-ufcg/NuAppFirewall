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
    
    private func createRule(action: String, app: String, endpoint: String, port: String) -> Rule? {
        let destination = "\(endpoint):\(port)"
        let ruleID = "\(app)-\(action)-\(destination)"
        
        return Rule(ruleID: ruleID, action: action, app: app, endpoint: endpoint, port: port) ?? nil
    }
    
    private func generateRuleData(
        apps: [String] = [TestConstants.appPath, TestConstants.appSubpath, TestConstants.bundleID],
        endpoints: [String] = [Consts.any, TestConstants.url, TestConstants.host, TestConstants.ip],
        actions: [String] = [Consts.verdictAllow, Consts.verdictBlock],
        ports: [String] = [Consts.any, TestConstants.port]
    ) -> [RuleData] {
        var ruleData: [RuleData] = []
        
        for app in apps {
            for endpoint in endpoints {
                for portValue in ports {
                    if endpoint == Consts.any && portValue != Consts.any {
                        continue
                    }
                    
                    for action in actions {
                        ruleData.append(RuleData(action: action, app: app, endpoint: endpoint, port: portValue))
                    }
                }
            }
        }
        
        return ruleData
    }

    // Test case: Validate that all possible combinations of rules are correctly initialized with accurate properties.
    func testRuleInitialization() {
        let ruleDataArray = generateRuleData()
        XCTAssertEqual(ruleDataArray.count, 42, "The number of all possible combinations must be 42.")
            
        for ruleData in ruleDataArray {
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertEqual(rule.ruleID, ruleData.ruleID, "Mismatch in ruleID for \(testInfo).")
            XCTAssertEqual(rule.action, ruleData.action, "Mismatch in action for \(testInfo).")
            XCTAssertEqual(rule.application, ruleData.app, "Mismatch in application for \(testInfo).")
            XCTAssertEqual(rule.endpoint, ruleData.endpoint, "Mismatch in endpoint for \(testInfo).")
            XCTAssertEqual(rule.port, ruleData.port, "Mismatch in port for \(testInfo).")
            XCTAssertEqual(rule.destination, ruleData.destination, "Mismatch in destination for \(testInfo).")
        }
    }
    
    // Test case: Ensure all possible rule combinations can be added successfully and validate their addition.
    func testAddRule() {
        let ruleDataArray = generateRuleData()
        XCTAssertEqual(ruleDataArray.count, 42, "The number of all possible combinations must be 42.")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create rule for \(testInfo)")
                continue
            }
            
            XCTAssertNoThrow(try rulesManager.addRule(rule), "Failed to add rule for \(testInfo).")
            
            let fetchedRule = rulesManager.getRule(bundleID: TestConstants.bundleID, appPath: TestConstants.appPath, url: TestConstants.url, host: TestConstants.host, ip: TestConstants.ip, port: TestConstants.port)
            XCTAssertNotNil(fetchedRule, "Rule was not retrieved for \(testInfo).")
            XCTAssertEqual(fetchedRule, rule, "Mismatch for \(testInfo). Retrieved: \(String(describing: fetchedRule)), Expected: \(String(describing: rule)).")
        }
    }
    
    // Test case: Ensure all possible rule combinations can be retrieved successfully after being added.
    func testRetrievalRule() {
        let ruleDataArray = generateRuleData()
        XCTAssertEqual(ruleDataArray.count, 42, "The number of all possible combinations must be 42.")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
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
        let ruleDataArray = generateRuleData()
        XCTAssertEqual(ruleDataArray.count, 42, "The number of all possible combinations must be 42.")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            let testInfo = "RuleID: \(ruleData.ruleID)"
            
            guard let rule = createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
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
    func testAddRuleWithSameParamsDifferentActionsAndEndpoints() {
        let ruleDataArray = generateRuleData()
        XCTAssertEqual(ruleDataArray.count, 42, "The number of all possible combinations must be 42.")
        
        for ruleData in ruleDataArray {
            rulesManager = RulesManager()
            let testInfo = "RuleID  \(ruleData.ruleID)"
            
            guard let rule1 = createRule(action: Consts.verdictAllow, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Failed to create first rule for \(testInfo).")
                continue
            }

            XCTAssertNoThrow(try rulesManager.addRule(rule1), "Failed to add the first rule for \(testInfo).")

            guard let rule2 = createRule(action: Consts.verdictBlock, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
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
        let bundleRules = generateRuleData(apps: [TestConstants.bundleID])
        let pathRules = generateRuleData(apps: [TestConstants.appPath])
        let subpathRules = generateRuleData(apps: [TestConstants.appSubpath])
        
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

                guard let allowRule = createRule(action: allowRuleData.action, app: allowRuleData.app, endpoint: allowRuleData.endpoint, port: allowRuleData.port
                ) else {
                    XCTFail("Failed to create allow rule: \(allowRuleData.ruleID)")
                    continue
                }

                XCTAssertNoThrow(try rulesManager.addRule(allowRule), "Failed to add allow rule: \(allowRuleData.ruleID)")
            }

            guard let blockRule = createRule(action: blockRuleData.action, app: blockRuleData.app, endpoint: blockRuleData.endpoint, port: blockRuleData.port
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
