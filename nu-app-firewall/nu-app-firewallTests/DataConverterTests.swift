import XCTest
@testable import nu_app_firewall

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
