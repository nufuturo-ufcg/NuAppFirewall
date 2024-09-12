/*
    File: DataConverterTests.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: Unit test class that uses XCTest to validate
               the behavior of the DataConverter class.
    
    Created by com.nufuturo.nuappfirewall
*/

import XCTest
@testable import NuAppFirewall

class DataConverterTests: XCTestCase {
    
    var dataConverter: DataConverter!

    override func setUp() {
        super.setUp()
        dataConverter = DataConverter()
    }

    override func tearDown() {
        dataConverter = nil
        super.tearDown()
    }
    
    func testReadData_ValidPlist() {
        let fileName = "SampleData"
        if let data = dataConverter.readData(from: fileName, ofType: .plist) {
            XCTAssertNotNil(data, "Expected the .plist file to be read correctly")
            XCTAssertTrue(data is [String: Any], "Expected the return to be a dictionary of type [String: Any]")
        } else {
            XCTFail("Failed to read valid .plist file")
        }
    }

    func testReadData_ValidJson() {
        let fileName = "SampleData"
        if let data = dataConverter.readData(from: fileName, ofType: .json) {
            XCTAssertNotNil(data, "Expected the .json file to be read correctly")
            XCTAssertTrue(data is [String: Any], "Expected the return to be a dictionary of type [String: Any]")
        } else {
            XCTFail("Failed to read valid .json file")
        }
    }
    
    func testReadData_ValidPlistContent() {
            let fileName = "SampleData"
            guard let data = dataConverter.readData(from: fileName, ofType: .plist) else {
                XCTFail("Failed to read valid .plist file")
                return
            }
            
            XCTAssertTrue(data is [String: Any], "Expected the .plist content to be of type [String: Any]")
            XCTAssertEqual(data["$version"] as? Int, 100000, "Expected $version to be 100000")
            XCTAssertEqual(data["$archiver"] as? String, "NSKeyedArchiver", "Expected $archiver to be 'NSKeyedArchiver'")
            
            if let objects = data["$objects"] as? [Any] {
                XCTAssertTrue(objects.contains { ($0 as? String) == "rules" }, "Expected 'rules' to be present in objects")
            } else {
                XCTFail("Expected $objects to be an array")
            }
        }
    
    func testReadData_ValidJsonContent() {
            let fileName = "SampleData"
            guard let data = dataConverter.readData(from: fileName, ofType: .json) else {
                XCTFail("Failed to read valid .json file")
                return
            }
            
            print("Conteúdo do JSON lido:", data)
            
            XCTAssertTrue(data is [String: Any], "Expected the JSON content to be of type [String: Any]")
            
            if let safariSearchHelper = data["/System/Volumes/Preboot/Cryptexes/Incoming/OS/System/Library/PrivateFrameworks/SafariShared.framework/Versions/A/XPCServices/com.apple.Safari.SearchHelper.xpc/Contents/MacOS/com.apple.Safari.SearchHelper"] as? [[String: Any]] {
                XCTAssertNotNil(safariSearchHelper, "Expected Safari Search Helper entry to be present")
                
                if let firstEntry = safariSearchHelper.first {
                    XCTAssertEqual(firstEntry["name"] as? String, "com.apple.Safari.SearchHelper", "Expected name to be 'com.apple.Safari.SearchHelper'")
                    XCTAssertEqual(firstEntry["endpointAddr"] as? String, "200.155.60.10", "Expected endpointAddr to be '200.155.60.10'")
                    XCTAssertTrue(
                        (firstEntry["endpointPort"] as? String == "53.0") || (firstEntry["endpointPort"] as? Int == 53),
                        "Expected endpointPort to be '53.0' or '53'"
                    )
                }
                
                if let secondEntry = safariSearchHelper.last {
                    XCTAssertEqual(secondEntry["name"] as? String, "com.apple.Safari.SearchHelper", "Expected name to be 'com.apple.Safari.SearchHelper'")
                    XCTAssertEqual(secondEntry["endpointAddr"] as? String, "142.250.218.3", "Expected endpointAddr to be '142.250.218.3'")
                    XCTAssertTrue(
                        (secondEntry["endpointPort"] as? String == "443.0") || (secondEntry["endpointPort"] as? Int == 443),
                        "Expected endpointPort to be '443.0' or '443'"
                    )
                }
            } else {
                XCTFail("Failed to parse Safari Search Helper section")
            }

            if let safeBrowsingService = data["/System/Library/PrivateFrameworks/SafariSafeBrowsing.framework/Versions/A/com.apple.Safari.SafeBrowsing.Service"] as? [[String: Any]] {
                XCTAssertNotNil(safeBrowsingService, "Expected Safari Safe Browsing Service entry to be present")

                if let firstEntry = safeBrowsingService.first {
                    XCTAssertEqual(firstEntry["name"] as? String, "com.apple.Safari.SafeBrowsing.Service", "Expected name to be 'com.apple.Safari.SafeBrowsing.Service'")
                    XCTAssertEqual(firstEntry["endpointAddr"] as? String, "10.101.231.53", "Expected endpointAddr to be '10.101.231.53'")
                    XCTAssertTrue(
                        (firstEntry["endpointPort"] as? String == "53.0") || (firstEntry["endpointPort"] as? Int == 53),
                        "Expected endpointPort to be '53.0' or '53'"
                    )
                }
            } else {
                XCTFail("Failed to parse Safari Safe Browsing Service section")
            }

            if let finderEntries = data["/System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"] as? [[String: Any]] {
                XCTAssertNotNil(finderEntries, "Expected Finder entry to be present")

                if let firstEntry = finderEntries.first {
                    XCTAssertEqual(firstEntry["name"] as? String, "Finder", "Expected name to be 'Finder'")
                    XCTAssertEqual(firstEntry["endpointAddr"] as? String, "192.168.1.1", "Expected endpointAddr to be '192.168.1.1'")
                    XCTAssertTrue(
                        (firstEntry["endpointPort"] as? String == "53") || (firstEntry["endpointPort"] as? Int == 53),
                        "Expected endpointPort to be '53' or 53"
                    )
                }
            } else {
                XCTFail("Failed to parse Finder section")
            }
        }

    func testReadPlistData_FileNotFound() {
        let fileName = "NonExistentFile"
        let data = dataConverter.readData(from: fileName, ofType: .plist)
        
        XCTAssertNil(data, "Expected the return to be nil for a non-existent .plist file")
    }
    
    func testReadJsonData_FileNotFound() {
        let fileName = "NonExistentFile"
        let data = dataConverter.readData(from: fileName, ofType: .json)
        
        XCTAssertNil(data, "Expected the return to be nil for a non-existent .json file")
    }
    
    func testReadData_InvalidPlistFormat() {
        let fileName = "InvalidFormatFile"
        let data = dataConverter.readData(from: fileName, ofType: .plist)
        
        XCTAssertNil(data, "Expected the return to be nil for a .plist file with invalid format")
    }
    
    func testReadData_InvalidJsonFormat() {
        let fileName = "InvalidFormatFile"
        let data = dataConverter.readData(from: fileName, ofType: .json)
        
        XCTAssertNil(data, "Expected the return to be nil for a .json file with invalid format")
    }
}
