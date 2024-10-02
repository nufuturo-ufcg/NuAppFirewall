/*
    File: LogEntry.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: LogManager is a class that manages log entries in a network content filter. It allows adding new entries and displaying existing ones, helping track and analyze network activities efficiently.
 
    Created by com.nufuturo.nuappfirewall
*/


import Foundation
import os

public class LogManager {
    
    public static let shared = LogManager()
    
    let logger = Logger(subsystem: "com.nufuturo.nuappfirewall.extension", category: "networking");
    
    public func log(_ message: String, level: OSLogType = .default) {
        logger.log(level: level, "\(message, privacy: .public)")
    }
    
    public func logError(_ error: Error) {
        logger.error("Error: \(error.localizedDescription, privacy: .public)")
    }
    
    public func logNewFlow(category: String, flowID: UUID, auditToken: audit_token_t, endpoint: String, url: String, level: OSLogType = .info) {
        
        let logEntry = LogEntry(category: category, flowID: flowID, auditToken: auditToken, endpoint: endpoint, url: url);

        logger.log("\(logEntry.formatLog(), privacy: .public)")
    }
}
