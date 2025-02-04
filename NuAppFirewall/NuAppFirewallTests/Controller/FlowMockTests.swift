//
//  FlowMockTests.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 08/11/24.
//

import XCTest
@testable import NuAppFirewall

class FlowMockTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    // Test case: Validate the initialization of FlowMock objects with all possible data combinations.
    func testFlowMockInitialization() {
        let flowDataArray = TestDataFactory.generateFlowData()
        XCTAssertEqual(flowDataArray.count, TestConstants.flowDataCombinationsCount, "The number of all possible combinations must be \(TestConstants.flowDataCombinationsCount).")
        
        for flowData in flowDataArray {
            let testInfo = "FlowData(url: \(flowData.url), host: \(flowData.host), ip: \(flowData.ip), app: \(flowData.app), port: \(flowData.port))"
            
            let flowMock = FlowMock(url: flowData.url, host: flowData.host, ip: flowData.ip, app: flowData.app, port: flowData.port)
            
            XCTAssertNotNil(flowMock, "The FlowMock object must be created for \(testInfo).")
            XCTAssertEqual(flowMock.url, flowData.url, "The url must be initialized correctly for \(testInfo).")
            XCTAssertEqual(flowMock.host, flowData.host, "The host must be initialized correctly for \(testInfo).")
            XCTAssertEqual(flowMock.ip, flowData.ip, "The ip must be initialized correctly for \(testInfo).")
            XCTAssertEqual(flowMock.app, flowData.app, "The app must be initialized correctly for \(testInfo).")
            XCTAssertEqual(flowMock.port, flowData.port, "The port must be initialized correctly for \(testInfo).")
        }
    }
}
