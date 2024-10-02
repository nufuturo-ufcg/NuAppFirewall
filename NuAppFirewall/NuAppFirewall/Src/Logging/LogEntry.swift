/*
    File: LogEntry.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: LogEntry is a class that represents a single log entry in a network content filter.
 
    Created by com.nufuturo.nuappfirewall
*/

import Foundation
import Darwin

public class LogEntry {
    
    let category: String
    let flowID: UUID
    let endpoint: String
    let token: audit_token_t
    let url: String
    var process: String
    
    init(category: String, flowID: UUID, auditToken: audit_token_t?, endpoint: String, url: String) {
        self.category = category
        self.flowID = flowID
        self.token = auditToken!
        self.endpoint = endpoint
        self.url = url
        self.process = "unknown"
        
        let pid = pidFromAuditToken(self.token)
        if let processPath = pathForProcess(with: pid) {
            self.process = processPath
        }
    }

    func pidFromAuditToken(_ auditToken: audit_token_t) -> pid_t {
        return pid_t(auditToken.val.5)
    }

    func pathForProcess(with pid: pid_t) -> String? {
        let bufferSize = Int(MAXPATHLEN)
        var buffer = [CChar](repeating: 0, count: bufferSize)
        let result = proc_pidpath(pid, &buffer, UInt32(bufferSize))
        
        if result > 0 {
            return String(cString: buffer)
        } else {
            return nil
        }
    }
    
    public func formatLog() -> String {
        return "CATEGORY=\(category), FLOW_ID=\(flowID), URL=\(url), PROCESS=\(process), ENDPOINT=\(endpoint)"
    }
}
