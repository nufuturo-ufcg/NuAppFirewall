//
//  FlowManagerTests.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 06/11/24.
//

import XCTest
@testable import NuAppFirewall

class FlowManagerMockTests: XCTestCase {
    
    var rulesManager: RulesManager!
    var flowManagerMock: FlowManagerMock!

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
    
    // Test case: Validate that the system correctly processes new flows against all possible rule combinations.
    func testHandleNewFlowWithRules() {
        let ruleDataArray = TestDataFactory.generateRuleData()
        XCTAssertEqual(ruleDataArray.count, TestConstants.ruleDataCombinationsCount, "O número total de combinações de regras deve ser \(TestConstants.ruleDataCombinationsCount).")
        
        let flowDataArray = TestDataFactory.generateFlowData()
        XCTAssertEqual(flowDataArray.count, TestConstants.flowDataCombinationsCount, "O número total de combinações de fluxos deve ser \(TestConstants.flowDataCombinationsCount).")
        
        for ruleData in ruleDataArray {
            
            guard let rule = TestDataFactory.createRule(action: ruleData.action, app: ruleData.app, endpoint: ruleData.endpoint, port: ruleData.port) else {
                XCTFail("Falha ao criar regra para RuleID: \(ruleData.ruleID)")
                continue
            }
            
            for flowData in flowDataArray {
                rulesManager = RulesManager()
                flowManagerMock = FlowManagerMock(rulesManager: rulesManager)
                
                XCTAssertNoThrow(try rulesManager.addRule(rule), "Falha ao adicionar a regra \(ruleData.ruleID).")
                
                let flowMock = FlowMock(url: flowData.url, host: flowData.host, ip: flowData.ip, app: flowData.app, port: flowData.port)
                
                let verdict = flowManagerMock.handleNewFlow(flow: flowMock)
                
                let testInfo = "RuleData(action: \(ruleData.action), app: \(ruleData.app), endpoint: \(ruleData.endpoint), port: \(ruleData.port)) | FlowData(url: \(flowData.url), host: \(flowData.host), ip: \(flowData.ip), port: \(flowData.port), application: \(flowData.app))"
                
                let isApplicationMatch = rule.application == flowData.app || flowData.app.contains(rule.application)

                let isEndpointMatch = rule.endpoint == flowMock.url ||
                                      rule.endpoint == flowMock.host ||
                                      rule.endpoint == flowMock.ip ||
                                      rule.endpoint == Consts.any

                let isPortMatch = rule.port == flowData.port || rule.port == Consts.any

                if isApplicationMatch && isEndpointMatch && isPortMatch {
                    let expectedVerdict = rule.action == TestConstants.actionBlock ? TestConstants.actionBlock : TestConstants.actionAllow
                    XCTAssertEqual(verdict, expectedVerdict, "Mismatch in verdict for \(testInfo). Esperado: \(expectedVerdict), Obtido: \(verdict).")
                } else {
                    XCTAssertEqual(verdict, Consts.verdictAllow, "Default verdict should be allow for \(testInfo).")
                }
            }
        }
    }
}
