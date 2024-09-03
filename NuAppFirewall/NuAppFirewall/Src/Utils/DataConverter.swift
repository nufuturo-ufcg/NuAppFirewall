//
//  File: DataConverter.swift
//  Project: App Firewall (nufuturo.nuappfirewall)
//  Description: Read and convert data from Property List (plist)
//               or JSON type files into a Swift dictionary.
//
//  Created by com.nufuturo.nuappfirewall
//

import Foundation

enum FileType {
    case plist
    case json
}

class DataConverter {
    func readData(from fileName: String, ofType type: FileType) -> [String: Any]? {
        
        guard let path = Bundle(for: DataConverter.self).path(forResource: fileName, ofType: type == .plist ? "plist" : "json") else {
                    return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        
        do {
            switch type {
            case .plist:
                if let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                    return dictionary
                }
            case .json:
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dictionary
                }
            }
        } catch {
            print("Error reading \(type == .plist ? "plist" : "JSON"): \(error)")
        }
        
        return nil
    }
}
