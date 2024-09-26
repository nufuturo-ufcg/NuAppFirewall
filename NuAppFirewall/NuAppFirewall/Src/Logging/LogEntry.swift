/*
    File: LogEntry.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: LogEntry is a class that represents a single log entry in a network content filter.
 
    Created by com.nufuturo.nuappfirewall
*/

import Foundation
import Security

public class LogEntry {
    
    let category: String
    let flowID: UUID
    let process: String
    let endpoint: String
    
    init(category: String, flowID: UUID, auditToken: audit_token_t?, endpoint: String) {
        self.category = category
        self.flowID = flowID
        self.process = LogEntry.getProcessPath(from: auditToken)
        self.endpoint = endpoint
    }
    
    private static func getProcessPath(from auditToken: audit_token_t?) -> String {
        guard let auditToken = auditToken else {
            return "Unknown"
        }
        
        let pid = pid_t(auditToken.val.0)
        
        return getProcessPathFromPID(pid: pid)
    }
    
    private static func getProcessPathFromPID(pid: pid_t) -> String {
        var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        let result = proc_pidpath(pid, &buffer, UInt32(buffer.count))
        if result > 0 {
            return String(cString: buffer)
        } else {
            return "Unknown"
        }
    }
    
    public func formatLog() -> String {
        return "CATEGORY=\(category), FLOW_ID=\(flowID), PROCESS=\(process), ENDPOINT=\(endpoint)"
    }
}
