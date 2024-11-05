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
    
    init(){
        rulesManager.loadRules(fileName: "test-rules", fileType: .json)
    }
    
    func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        
        LogManager.logManager.log("handling new flow in FlowManager", level: .debug, functionName: #function)
        
        let (flowID, endpoint, url, subdomain, port, auditToken) = extractFlowInfo(from: flow)
        let pid = pidFromAuditToken(auditToken)
        let path = pathForProcess(with: pid)
        
        LogManager.logManager.log("New flow SUBDOMAIN: \(subdomain)")
        LogManager.logManager.log("New flow URL: \(url)")
        LogManager.logManager.log("New flow PATH: \(path)")
        LogManager.logManager.log("New flow PORT: \(port)")
        
        if let rule = rulesManager.getRule(appPath: path, endpoint: subdomain, port: port) {
            let verdict: NEFilterNewFlowVerdict = rule.action == Consts.verdictBlock ? .drop() : .allow()
            let actionVerdict = rule.action == Consts.verdictBlock ? Consts.verdictBlock : Consts.verdictAllow
            
            LogManager.logManager.log(rule.description())
            LogManager.logManager.logNewFlow(category: Consts.categoryConnection, flowID: flowID, auditToken: auditToken, endpoint: endpoint,mode: Consts.modePassive, url: url, verdict: actionVerdict, process: path, ruleID: rule.ruleID)
            
            return verdict
        } else {
            LogManager.logManager.logNewFlow(category: Consts.categoryConnection, flowID: flowID, auditToken: auditToken, endpoint: endpoint, mode: Consts.modePassive, url: url, verdict: Consts.verdictAllow, process: path, ruleID: Consts.NoneString)
            
            return NEFilterNewFlowVerdict.allow();
        }
    }
    
    private func extractFlowInfo(from flow: NEFilterFlow) -> (UUID, String, String, String, String, audit_token_t) {
        LogManager.logManager.log("extracting log info", level: .debug, functionName: #function)
        
        let flowID = flow.identifier
        
        var endpoint = "unknown"
        var port = "unknown"
        var auditToken = audit_token_t()
        
        if let socketFlow = flow as? NEFilterSocketFlow {
            if let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint {
                endpoint = remoteEndpoint.hostname
                port = remoteEndpoint.port
                
                if let data = socketFlow.sourceAppAuditToken {
                    auditToken = data.withUnsafeBytes { ptr -> audit_token_t in
                        guard let baseAdress = ptr.baseAddress else {return auditToken}
                        return baseAdress.load(as: audit_token_t.self)}
                }
            }
        }
        
        let url = flow.url?.absoluteString ?? "unknown"
        let subdomain = flow.url?.host(percentEncoded: true) ?? "unknown"
        
        return (flowID, endpoint, url, subdomain, port, auditToken)
    }
    
    func pidFromAuditToken(_ auditToken: audit_token_t) -> pid_t {
        return pid_t(auditToken.val.5)
    }
    
    func pathForProcess(with pid: pid_t) -> String {
        
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
