//
//  FlowManager.swift
//  Extension
//
//  Created by ec2-user on 07/10/2024.
//

import Foundation
import SystemExtensions
import NetworkExtension

public class FlowManager {
    
    let rulesManager = RulesManager();
    
    func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        
        LogManager.logManager.log("handling new flow in FlowManager", level: .debug, functionName: #function)
        
        let (flowID, endpoint, url, auditToken) = extractFlowInfo(from: flow)
        
        let pid = pidFromAuditToken(auditToken)
        
        var path: String = "unknown"
        
        if let processPath = pathForProcess(with: pid) {
            path = processPath
        }
        
        if path != "unknown" {
            let appRules = rulesManager.getRules(byApp: path);
            
            for rule in appRules {
                LogManager.logManager.log(rule.description())
                for endpoint in rule.endpoints {
                    if url.contains(endpoint) {
                        if rule.action == "0" {
                            LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint,mode: "passive mode", url: url, verdict: "block", process: path, ruleID: rule.ruleID)
                            return .drop()
                        } else {
                            LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint, mode: "passive-mode", url: url, verdict: "allow", process: path, ruleID: rule.ruleID)
                            return .allow()
                        }
                    }
                }
            }
        }

        LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint, mode: "passive mode", url: url, verdict: "allow", process: path, ruleID: "None")
        return NEFilterNewFlowVerdict.allow();
    }
    
    private func extractFlowInfo(from flow: NEFilterFlow) -> (UUID, String, String, audit_token_t) {
        LogManager.logManager.log("extracting log info", level: .debug, functionName: #function)
        
        let flowID = flow.identifier
        
        var endpoint = "unknown"
        var auditToken = audit_token_t()
        
        if let socketFlow = flow as? NEFilterSocketFlow {
            if let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint {
                endpoint = remoteEndpoint.hostname
                
                if let data = socketFlow.sourceAppAuditToken {
                    auditToken = data.withUnsafeBytes { ptr -> audit_token_t in
                        guard let baseAdress = ptr.baseAddress else {return auditToken}
                        return baseAdress.load(as: audit_token_t.self)}
                }
            }
        }
        
        let url = flow.url?.absoluteString ?? "unknown"
        
        return (flowID, endpoint, url, auditToken)
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
            return "unknown"
        }
    }
}
