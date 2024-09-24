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
    
    public func log(_ message: String) {
        logger.log("\(message)")
    }
    
    public func log(_ message: String, _ type: OSLogType) {
        logger.log(level: type, "\(message)")
    }
    
    public func logError(error: Error) {
        logger.error("Error: \(error.localizedDescription)")
    }
    
    public func logNewFLow(category: String, flowID: String, process: String, endpoint: String) {
        let logFlow = LogEntry(category: category, flowID: flowID, process: process, endpoint: endpoint);
        logger.log("\(logFlow.getRepresentation())")
    }
    
}
