//
//  FlowManagerTests.swift
//  NuAppFirewall
//
//  Created by Walber Araújo on 06/11/24.
//
/*
import XCTest
@testable import NuAppFirewall

class FlowManagerTests: XCTestCase {
    
    var rulesManager: RulesManager!
    var flowManagerMock: FlowManagerMock!
    
    let appLocation = "appPath/Test"
    let url = "url/Test"
    let host = "host/Test"
    let ip = "123"
    let port = "443"
    let action = "allow"

    override func setUp() {
        super.setUp()
        rulesManager = RulesManager()
        flowManagerMock = FlowManagerMock(rulesManager: rulesManager)
    }

    override func tearDown() {
        rulesManager = nil
        flowManagerMock = nil
        super.tearDown()
    }
    
    // Test case: test handle new flow without matching rule
    func testHandleNewFlowNoMatchRulePassiveMode() {
        let fetchedRule = rulesManager.getRule(bundleID: "", appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNil(fetchedRule, "No rule should be found with a non-existent data")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictAllow, "The verdict should be equal to the one defined in the rule.")
    }
    
    /*
    // Test case: test handle new flow with matching rule and allow verdict
    func testHandleNewFlowMatchRuleAllowVerdict() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(Consts.verdictAllow)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictAllow, "The verdict should be equal to the one defined in the rule")
    }
    
    // Test case: test handle new flow with matching rule and block verdict
    func testHandleNewFlowMatchRuleBlockVerdict() {
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by url and defined port
    func testHandleNewFlowSearchByUrl() {
        let flow = FlowMock(url: url, host: Consts.unknown, ip: Consts.unknown, path: appLocation, port: port)
        
        let destination = "\(url):\(port)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by url and undefined port
    func testHandleNewFlowSearchByUrlAnyPort() {
        let flow = FlowMock(url: url, host: Consts.unknown, ip: Consts.unknown, path: appLocation, port: Consts.unknown)
        
        let destination = "\(url):\(Consts.any)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: url, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by ip and defined port
    func testHandleNewFlowSearchByIp() {
        let flow = FlowMock(url: Consts.unknown, host: Consts.unknown, ip: ip, path: appLocation, port: port)
        
        let destination = "\(ip):\(port)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by ip and undefined port
    func testHandleNewFlowSearchByIpAnyPort() {
        let flow = FlowMock(url: Consts.unknown, host: Consts.unknown, ip: ip, path: appLocation, port: Consts.unknown)
        
        let destination = "\(ip):\(Consts.any)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: ip, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by host and defined port
    func testHandleNewFlowSearchByHost() {
        let flow = FlowMock(url: url, host: host, ip: Consts.unknown, path: appLocation, port: port)
        
        let destination = "\(host):\(port)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule.")
    }
    
    // Test case: test handle new flow with matching rule searching by host and undefined port
    func testHandleNewFlowSearchByHostAnyPort() {
        let flow = FlowMock(url: url, host: host, ip: Consts.unknown, path: appLocation, port: Consts.unknown)
        
        let destination = "\(host):\(Consts.any)"
        let ruleID = "\(appLocation)-\(Consts.verdictBlock)-\(destination)"
        let rule = Rule(ruleID: ruleID, action: Consts.verdictBlock, appLocation: appLocation, endpoint: host, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule), "Should add a specific rule without error")
        
        let fetchedRule = rulesManager.getRule(appPath: flow.path, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port)
        XCTAssertNotNil(fetchedRule, "The rule should be found with existent data")
        XCTAssertEqual(fetchedRule, rule, "The fetched rule should match the one added")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "The verdict should be equal to the one defined in the rule")
    }
    
    // Test case: Test handleNewFlow to prioritize "block" rule when both "allow" and "block" rules exist
    func testHandleNewFlowPreferenceBlockAll() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(Consts.any):\(Consts.any)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a 'block all' rule without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(Consts.any):\(Consts.any)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: Consts.any, port: Consts.any)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictBlock)-\(url):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictBlock)-\(host):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for host without error")
        
        let ruleID5 = "\(appLocation)-\(Consts.verdictBlock)-\(ip):\(port)"
        let rule5 = Rule(ruleID: ruleID5, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule5), "Should add a specific 'allow' rule for IP without error")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the 'block all' rule")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match a specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match a host-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule5, "Fetched rule should not match an IP-specific 'allow' rule")
        
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "Verdict should reflect the 'block' rule preference")
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
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "Verdict should reflect the 'block' rule preference by URL")
    }

    // Test case: Test handleNewFlow to prioritize "block" rule by host over "allow".
    func testHandleNewFlowBlockPreferenceByHostOverAllow() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(host):\(port)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a specific 'block' rule for host without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(host):\(port)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint, and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(ip):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for IP without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(url):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for URL without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the specific 'block' rule for host")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match an IP-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match a URL-specific 'allow' rule")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "Verdict should reflect the 'block' rule preference by host")
    }

    // Test case: Test handleNewFlow to prioritize "block" rule by IP over "allow".
    func testHandleNewFlowBlockPreferenceByIpOverAllow() {
        let ruleID1 = "\(appLocation)-\(Consts.verdictBlock)-\(ip):\(port)"
        let rule1 = Rule(ruleID: ruleID1, action: Consts.verdictBlock, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule1), "Should add a specific 'block' rule for IP without error")
        
        let ruleID2 = "\(appLocation)-\(Consts.verdictAllow)-\(ip):\(port)"
        let rule2 = Rule(ruleID: ruleID2, action: Consts.verdictAllow, appLocation: appLocation, endpoint: ip, port: port)
        XCTAssertThrowsError(try rulesManager.addRule(rule2), "Should prevent adding a rule with duplicate appLocation, endpoint, and port")
        
        let ruleID3 = "\(appLocation)-\(Consts.verdictAllow)-\(url):\(port)"
        let rule3 = Rule(ruleID: ruleID3, action: Consts.verdictAllow, appLocation: appLocation, endpoint: url, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule3), "Should add a specific 'allow' rule for URL without error")
        
        let ruleID4 = "\(appLocation)-\(Consts.verdictAllow)-\(host):\(port)"
        let rule4 = Rule(ruleID: ruleID4, action: Consts.verdictAllow, appLocation: appLocation, endpoint: host, port: port)
        XCTAssertNoThrow(try rulesManager.addRule(rule4), "Should add a specific 'allow' rule for host without error")
        
        let fetchedRule = rulesManager.getRule(appPath: appLocation, url: url, host: host, ip: ip, port: port)
        XCTAssertNotNil(fetchedRule, "Should fetch a rule with an existing ID.")
        XCTAssertEqual(fetchedRule, rule1, "Fetched rule should match the specific 'block' rule for IP")
        XCTAssertNotEqual(fetchedRule, rule2, "Fetched rule should not match a duplicate rule")
        XCTAssertNotEqual(fetchedRule, rule3, "Fetched rule should not match a URL-specific 'allow' rule")
        XCTAssertNotEqual(fetchedRule, rule4, "Fetched rule should not match a host-specific 'allow' rule")
        
        let flow = FlowMock(url: url, host: host, ip: ip, path: appLocation, port: port)
        let verdict = flowManagerMock.handleNewFlow(flow: flow)
        XCTAssertEqual(verdict, Consts.verdictBlock, "Verdict should reflect the 'block' rule preference by IP")
    }*/
}
*/
