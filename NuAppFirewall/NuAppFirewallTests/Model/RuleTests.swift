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
    
    // Test case: Validate the initialization of Rule objects for all possible rule combinations.
    func testRuleInitialization() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port))"
            
            let rule = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
            
            XCTAssertNotNil(rule, "The rule must be created for \(testInfo).")
            XCTAssertEqual(rule?.ruleID, ruleData.ruleID, "Mismatch in ruleID for \(testInfo).")
        }
    }
    
    // Test case: Verify that the description method outputs the correct string format for all possible rule combinations.
    func testRuleDescription() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port))"
            
            let rule = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
            let description = rule?.description()
            let expectedDescription = """
            ruleID: \(ruleData.ruleID)
            Action: \(ruleData.action)
            Application: \(ruleData.app)
            Endpoint: \(ruleData.endpoint)
            Destination: \(ruleData.endpoint):\(ruleData.port)
            Port: \(ruleData.port)
            """
            
            XCTAssertEqual(description, expectedDescription, "Description mismatch for \(testInfo).")
        }
    }
    
    // Test case: Validate the equality comparison for Rule objects.
    func testRuleEquality() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port))"
            
            let rule1 = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
            let rule2 = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
            
            // Ensure rule1 and rule2 are equal
            XCTAssertEqual(rule1, rule2, "Rules with the same properties should be equal for \(testInfo).")
            
            // Create a different rule for comparison
            let rule3 = Rule(ruleID: "/Applications/DifferentApp.app", action: TestConstants.actionBlock, app: "/Applications/DifferentApp.app", endpoint: "10.0.0.1", port: "443")
            
            // Ensure rule1 and rule3 are not equal
            XCTAssertNotEqual(rule1, rule3, "Rules with different properties should not be equal for \(testInfo).")
        }
    }
    
    // Teste case: Ensure that the hash(into:) function generates consistent hashes for identical rules and different hashes for distinct rules.
    func testRuleHashing() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")
            
        for ruleData in ruleDataArray {
            let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port))"
                
            let rule1 = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
            let rule2 = Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port)
                
            XCTAssertEqual(rule1.hashValue, rule2.hashValue, "Hash values should be equal for identical rules: \(testInfo).")
                
            let rule3 = Rule(ruleID: "/Applications/DifferentApp.app", action: TestConstants.actionBlock, app: "/Applications/DifferentApp.app", endpoint: "10.0.0.1", port: "443")
                
            XCTAssertNotEqual(rule1.hashValue, rule3.hashValue, "Hash values should differ for distinct rules: \(testInfo).")
        }
    }
    
    // Test Case: Ensure that the Rule initializer fails when any required field is empty.
    func testRuleInitializationFailsForEmptyValues() {
        let ruleDataArray = TestDataFactory.generateRuleData()

        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount,
                       "The number of all possible combinations must be \(TestConstants.ruleDataCombinationsCount).")

        for ruleData in ruleDataArray {
            let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port))"

            let invalidRules = [
                Rule(ruleID: "", action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port),
                Rule(ruleID: ruleData.ruleID, action: "", app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port),
                Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: "", endpoint: ruleData.endpoint, port: ruleData.port),
                Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: "", port: ruleData.port),
                Rule(ruleID: ruleData.ruleID, action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: "")
            ]

            for (index, rule) in invalidRules.enumerated() {
                XCTAssertNil(rule, "Rule initialization should fail for empty value at index \(index): \(testInfo)")
            }
        }
    }
}
