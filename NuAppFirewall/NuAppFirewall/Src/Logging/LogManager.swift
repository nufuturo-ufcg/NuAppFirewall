/*
    File: LogManager.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: LogManager is a class that manages log entries in a network content filter. It allows adding new entries and displaying existing ones, helping track and analyze network activities efficiently.
 
    Created by com.nufuturo.nuappfirewall
*/


import Foundation
import os

public class LogManager {
    
    public static let logManager = LogManager()
    
    let logger = Logger(subsystem: "com.nufuturo.nuappfirewall.extension", category: "networking");
    
    public func log(_ message: String, level: OSLogType = .default, functionName: String = #function) {
        switch level {
        case .debug:
            logger.log(level: .debug, "\(self.formatDebugLog(functionName, message), privacy: .public)")
        default:
            logger.log(level: level, "\(message, privacy: .public)")
        }
    }
    
    public func logError(_ error: Error) {
        logger.error("Error: \(error.localizedDescription, privacy: .public)")
    }
    
    public func logNewFlow(category: String, flowID: UUID, auditToken: audit_token_t, endpoint: String, port: String, mode: String, url: String, verdict: String, process: String, ruleID: String, level: OSLogType = .info) {
        let message = "\"CATEGORY=\(category), FLOW_ID=\(flowID), URL=\(url), PROCESS=\(process), ENDPOINT=\(endpoint), PORT=\(port), MODE=\(mode), RULE_ID=\(ruleID), VERDICT=\(verdict)"
        logger.log(level: level, "\(message, privacy: .public)")
    }
    
    private func getCurrentTimestamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let result = formatter.string(from: date)
        return result
    }
    
    private func formatDebugLog(_ functionName: String, _ message: String) -> String {
        return "[DEBUG] function: \(functionName), timestamp: \(self.getCurrentTimestamp()), message: \(message)"
    }
}
