/*
    File: RulesManagerTests.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: Unit test class that uses XCTest to validate
        the behavior of the RulesManager class.

    Created by com.nufuturo.nuappfirewall
*/

/*
import XCTest
@testable import NuAppFirewall

class RulesManagerTests: XCTestCase {

    var rulesManager: RulesManager!
    
    let action = "allow"
    let appLocation = "/Applications/MyApp"
    let url = "www.teste.com"
    let host = "teste.com"
    let ip = "123.123.123"
    let port = "443"

    override func setUp() {
        super.setUp()
        rulesManager = RulesManager()
    }

    override func tearDown() {
        rulesManager = nil
        super.tearDown()
    }

    // Test case: Rule Initialization
    func testRuleInitialization() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: url, port: port)

        XCTAssertNotNil(rule, "The rule must be created")
        XCTAssertEqual(rule?.ruleID, ruleID, "The ruleID must be initialized correctly.")
        XCTAssertEqual(rule?.action, action, "The action must be initialized correctly.")
        XCTAssertEqual(rule?.appLocation, appLocation, "The application location must be initialized correctly.")
        XCTAssertEqual(rule?.endpoint, url, "The endpoint must be initialized correctly.")
        XCTAssertEqual(rule?.port, port, "The port must be initialized correctly.")
        XCTAssertEqual(rule?.destination, destination, "The destination must be initialized correctly.")
    }
    
    // Test case: Add a rule
    func testAddRule() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved.")
        XCTAssertEqual(fetchedRule, rule, "The rule should match.")
    }

    // Test case: Add another rule with different attributes
    func testAddAnotherRule() {
        let destination1 = "\(url):\(port)"
        let ruleID1 = "\(appLocation)-\(action)-\(destination1)"
        let rule1 = Rule(ruleID: ruleID1, action: action, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add the rule1 without error")
        
        let appPath = "/Applications/MyApp2"
        let endpoint = "www.teste2.com"
        let port = "any"
        let action = Consts.verdictBlock
        let destination2 = "\(endpoint):\(port)"
        let ruleID2 = "\(appPath)-\(action)-\(destination2)"
        let rule2 = Rule(ruleID: ruleID2, action: action, appLocation: appPath, endpoint: endpoint, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule2), "Should add the rule2 without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appPath, url: endpoint, host: "teste2.com", ip: "321.321.321.321", port: port)
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved")
        XCTAssertEqual(fetchedRule, rule2, "The rule should match")
    }
    
    // Test case: Add a generic rule and retrieve it by any URL, host, or IP
    func testGenericRuleMatch() {
        let destination = "\(Consts.any):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Generic rule should be retrieved for any URL, host, or IP")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Add a rule and retrieve by URL and defined port
    func testRuleMatchUrlAndPort() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: Consts.unknown, ip: Consts.unknown, port: port)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for URL and Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Add a rule and retrieve by URL and any port
    func testRuleMatchUrlAndAnyPort() {
        let destination = "\(url):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: url, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: Consts.unknown, ip: Consts.unknown, port: Consts.unknown)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for URL and any Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Add a rule and retrieve by Host and defined port
    func testRuleMatchHostAndPort() {
        let destination = "\(host):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: Consts.unknown, port: port)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for Host and Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Add a rule and retrieve by Host and any port
    func testRuleMatchHostAndAnyPort() {
        let destination = "\(host):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: host, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: Consts.unknown, port: Consts.unknown)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for Host and any Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Add a rule and retrieve by IP and defined port
    func testRuleMatchIpAndPort() {
        let destination = "\(ip):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: Consts.unknown, host: Consts.unknown, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for IP and Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }
    
    // Test case: Adding a rule and retrieving by IP and any port
    func testRuleMatchIpAndAnyPort() {
        let destination = "\(ip):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: action, appLocation: appLocation, endpoint: ip, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: Consts.unknown, host: Consts.unknown, ip: ip, port: Consts.unknown)
        XCTAssertNotNil(fetchedRule, "The rule should be retrieved for IP and any Port")
        XCTAssertEqual(fetchedRule?.action, action, "The action should match the added rule")
    }

    // Test case: Attempt to retrieve a rule that doesn't exist
    func testRetrieveNonExistentRule() {
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNil(fetchedRule, "No rule should be found with a non-existent data")
    }

    // Test case: Remove an existing rule by url and defined port
    func testRemoveExistingRuleByUrl() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil.")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: url, host: Consts.unknown, ip: Consts.unknown, port: port)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal.")
    }
    
    // Test case: Remove an existing rule by url and any port
    func testRemoveExistingRuleByUrlAndAnyPort() {
        let destination = "\(url):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: url, host: Consts.unknown, ip: Consts.unknown, port: Consts.unknown)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal")
    }
    
    // Test case: Remove an existing rule by host and defined port
    func testRemoveExistingRuleByHost() {
        let destination = "\(host):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil.")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: Consts.unknown, port: port)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal.")
    }
    
    // Test case: Remove an existing rule by host and any port
    func testRemoveExistingRuleByHostAndAnyPort() {
        let destination = "\(host):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: Consts.unknown, port: Consts.unknown)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal")
    }
    
    // Test case: Remove an existing rule by ip and defined port
    func testRemoveExistingRuleByIp() {
        let destination = "\(ip):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil.")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: Consts.unknown, host: Consts.unknown, ip: ip, port: port)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal.")
    }
    
    // Test case: Remove an existing rule by ip and any port
    func testRemoveExistingRuleByIpAndAnyPort() {
        let destination = "\(ip):\(Consts.any)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let removedRule = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(removedRule, "The removed rule must not be nil")

        let fetchedRuleAfterRemoval = rulesManager.getRule(appPath: appLocation, url: Consts.unknown, host: Consts.unknown, ip: ip, port: Consts.unknown)
        XCTAssertNil(fetchedRuleAfterRemoval, "Rule must be nil after removal")
    }

    // Test case: Try to remove a rule that has already been removed
    func testRemoveAlreadyRemovedRule() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(action)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add the rule without error")

        let firstRemoval = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNotNil(firstRemoval, "The first removal should return the removed rule.")

        let secondRemoval = rulesManager.removeRule(appPath: appLocation, destination: destination)
        XCTAssertNil(secondRemoval, "The second removal should return nil, as the rule has already been removed.")
    }

    // Test case: Add a rule with the same appLocation and destination and validate if first remains
    func testAddRuleWithSameAppLocationAndDestinationFirstRemains() {
        let verdict1 = Consts.verdictAllow
        let destination = "\(url):\(port)"
        let ruleID1 = "\(appLocation)-\(verdict1)-\(destination)"
        let rule1 = Rule(ruleID: ruleID1, action: verdict1, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add the rule without error")
        
        let verdict2 = Consts.verdictBlock
        let ruleID2 = "\(appLocation)-\(verdict2)-\(destination)"
        let rule2 = Rule(ruleID: ruleID2, action: verdict2, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should not add the rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: Consts.unknown, ip: Consts.unknown, port: port)
        XCTAssertNotNil(fetchedRule, "Rule should be retrieved.")
        XCTAssertEqual(fetchedRule, rule1, "The fetched rule should match with rule1")
        XCTAssertNotEqual(fetchedRule, rule2, "The fetched rule should not match with rule2")
    }
    
    // Test case: Test handleNewFlow to prioritize block all rule with a full path over "allow"
    func testPreferenceBlockAllFullPath() {
        let destination = "\(Consts.any):\(Consts.any)"
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a general 'block all' rule without error")
        
        let destination2 = "\(Consts.any):\(Consts.any)"
        let ruleID2 = "\(appLocation)-\(Consts.verdictBlock)-\(destination2)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let destination3 = "\(url):\(port)"
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(destination3)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for URL without error")
        
        let destination4 = "\(host):\(port)"
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(destination4)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for URL without error")
        
        let destination5 = "\(ip):\(port)"
        let ruleID5 = "\(appLocation)-\(Consts.verdictAllow)-\(destination5)"
        let rule5 = Rule(ruleID: ruleID5, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule5), "Should add a specific 'allow' rule for URL without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the general 'block all' rule")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule5, "Fetched rule should not match the specific 'allow' rule")
    }
    
    // Test case: Test handleNewFlow to prioritize block all rule with only a subpath over "allow"
    func testPreferenceBlockAllSubPath() {
        // Arrange
        // With every creation of a rule, there will be an assert to verify if it was really added without error to the RulesManager.
        let destination = "\(Consts.any):\(Consts.any)"
        let ruleID1 = "\("MyApp")-\(Consts.verdictBlock)-\(destination)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a general 'block all' rule without error")
        
        let destination2 = "\(Consts.any):\(Consts.any)"
        let ruleID2 = "\(appLocation)-\(Consts.verdictBlock)-\(destination2)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let destination3 = "\(url):\(port)"
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(destination3)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for URL without error")
        
        let destination4 = "\(host):\(port)"
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(destination4)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for URL without error")
        
        let destination5 = "\(ip):\(port)"
        let ruleID5 = "\(appLocation)-\(Consts.verdictAllow)-\(destination5)"
        let rule5 = Rule(ruleID: ruleID5, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule5), "Should add a specific 'allow' rule for URL without error")
        
        // Act
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        
        // Assert
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the general 'block all' rule")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match the specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule5, "Fetched rule should not match the specific 'allow' rule")
    }

    // Test case: Test handleNewFlow to prioritize "block" rule by URL over "allow"
    func testHandleNewFlowBlockPreferenceByUrlOverAllow() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(url):\(port)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a specific 'block' rule for URL without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(url):\(port)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(host):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for host without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(ip):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for IP without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the specific 'block' rule for URL")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match a host-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match an IP-specific 'allow' rule")
    }

    // Test case: Test getRule to prioritize "block" rule by IP over "allow"
    func testBlockPreferenceByIpOverAllow() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(ip):\(port)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a specific 'block' rule for IP without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(ip):\(port)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(host):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for host without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(url):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for URL without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the specific 'block' rule for IP")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match a host-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match a URL-specific 'allow' rule")
    }

    // Test case: Test getRule to prioritize "block" rule by Host over "allow"
    func testBlockPreferenceByHostOverAllow() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(host):\(port)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a specific 'block' rule for Host without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(host):\(port)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(url):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for URL without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(ip):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for IP without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the specific 'block' rule for Host")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match a URL-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match an IP-specific 'allow' rule")
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
}*/
