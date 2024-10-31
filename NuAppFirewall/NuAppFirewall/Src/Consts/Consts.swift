//
//  Consts.swift
//  Extension
//
//  Created by ec2-user on 22/10/2024.
//

import Foundation

struct Consts {
    static let categoryConnection = "connection"
    static let modePassive = "passive"
    static let verdictAllow = "allow"
    static let verdictBlock = "block"
    static let NoneString = "None"
    
    static let filePath: URL? = {
        let fileManager = FileManager.default
        
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "27XB45N6Y5.com.nufuturo.nuappfirewall") else {
            LogManager.logManager.log("Unable to find container URL")
            return nil
        }
        
        let appSupportURL = containerURL.appendingPathComponent("Library/Application Support")
            
        return appSupportURL
    }()
}

