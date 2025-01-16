/*
    File: DataConverter.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: Read and convert data from Property List (plist)
               or JSON type files into a Swift dictionary.

    Created by com.nufuturo.nuappfirewall
*/

import Foundation

enum FileType {
    case plist
    case json
}

class DataConverter {
    func readManagedData() -> [String: Any]? {
        
        let domain = "com.nufuturo.nuappfirewall"
        let key = "ruleSet"
        
        guard let data = CFPreferencesCopyAppValue(key as CFString, domain as CFString) else {
            LogManager.logManager.log("No value found for key \(key) in managed preferences domain \(domain).")
            return nil
        }
        
        if let dictionary = data as? [String: Any] {
            LogManager.logManager.log("Data loaded from managed preferences domain \(domain).")
            return dictionary
        } else {
            LogManager.logManager.log("The value found for key \(key) is not a dictionary.")
            return nil
        }
    }
    
    func readData(from fileName: String, ofType type: FileType) -> [String: Any]?
    {
        
        guard let containerURL = Consts.filePath else {
            LogManager.logManager.log("Unable to find container URL")
            return nil
        }

        var filePath: URL
        
        switch type {
        case .plist:
            filePath = containerURL.appendingPathComponent("\(fileName).plist")
        case .json:
            filePath = containerURL.appendingPathComponent("\(fileName).json")
        }
        
        LogManager.logManager.log("Accessing file from path: \(filePath.path)")
        
        guard FileManager.default.isReadableFile(atPath: filePath.path) else {
            LogManager.logManager.log("File not accessible or does not exist: \(filePath.path)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: filePath) else {
            LogManager.logManager.log("Error reading data from file: \(filePath.path)")
            return nil
        }
        
        do{
            switch type{
            case .plist:
                if let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]{
                    LogManager.logManager.log("Data loaded from PLIST: \(dictionary)")
                    return dictionary
                }
            case .json:
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    LogManager.logManager.log("Data loaded from JSON: \(dictionary)")
                    return dictionary
                }
            }
        } catch {
            LogManager.logManager.log("Error reading file: \(error)")
        }
        
        return nil
    }
}
