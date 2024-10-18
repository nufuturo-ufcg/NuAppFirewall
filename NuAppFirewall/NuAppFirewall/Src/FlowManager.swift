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
    
    func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        
        LogManager.logManager.log("handling new flow in FlowManager", level: .debug, functionName: #function)
        
        let (flowID, endpoint, url, auditToken) = extractLogInfo(from: flow)
        
        if url.contains("youtube.com") {
            LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint, url: url, verdict: "block")
            
            return .drop()
        }
        
        LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint, url: url, verdict: "allow")
        
        return NEFilterNewFlowVerdict.allow();
    }
    
    private func extractLogInfo(from flow: NEFilterFlow) -> (UUID, String, String, audit_token_t) {
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
}
