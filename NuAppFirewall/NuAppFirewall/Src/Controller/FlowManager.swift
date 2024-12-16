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
        rulesManager.loadRules(fileName: "rules", fileType: .json)
    }
    
    func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        LogManager.logManager.log("handling new flow in FlowManager", level: .debug, functionName: #function)
        
        let (flowID, endpoint, url, host, port, auditToken) = extractFlowInfo(from: flow)
        let pid = pidFromAuditToken(auditToken)
        let path = pathForProcess(with: pid)
        let bundleID = getBundleID(from: path)
        
        if let rule = rulesManager.getRule(bundleID: bundleID, appPath: path, url: url, host: host, ip: endpoint, port: port) {
            let verdict: NEFilterNewFlowVerdict = rule.action == Consts.verdictBlock ? .drop() : .allow()
            
            LogManager.logManager.log(rule.description())
            LogManager.logManager.logNewFlow(category: Consts.categoryConnection, flowID: flowID, auditToken: auditToken, endpoint: endpoint, port: port, mode: Consts.modePassive, url: url, verdict: rule.action, process: path, ruleID: rule.ruleID)
            
            return verdict
        } else {
            LogManager.logManager.logNewFlow(category: Consts.categoryConnection, flowID: flowID, auditToken: auditToken, endpoint: endpoint, port: port, mode: Consts.modePassive, url: url, verdict: Consts.verdictAllow, process: path, ruleID: Consts.NoneString)
            
            return NEFilterNewFlowVerdict.allow();
        }
    }
    
    private func extractFlowInfo(from flow: NEFilterFlow) -> (UUID, String, String, String, String, audit_token_t) {
        LogManager.logManager.log("extracting log info", level: .debug, functionName: #function)
        
        let flowID = flow.identifier
        
        var endpoint = Consts.unknown
        var port = Consts.unknown
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
        
        let url = flow.url?.absoluteString ?? Consts.unknown
        let host = flow.url?.host(percentEncoded: true) ?? Consts.unknown
        
        return (flowID, endpoint, url, host, port, auditToken)
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
            return Consts.unknown
        }
    }
    
    func getBundleID(from applicationPath: String) -> String {
        guard let bundlePath = findBundlePath(in: applicationPath) else {
            return Consts.unknown
        }
        
        if let bundle = Bundle(path: bundlePath) {
            return bundle.bundleIdentifier ?? Consts.unknown
        }
        
        let plistPath = "\(bundlePath)/Contents/Info.plist"
        if let plistData = NSDictionary(contentsOfFile: plistPath),
           let bundleID = plistData["CFBundleIdentifier"] as? String {
            return bundleID
        }
        
        return Consts.unknown
    }

    func findBundlePath(in path: String) -> String? {
        let components = path.split(separator: "/")
        
        for i in (0..<components.count).reversed() {
            let subPath = "/" + components.prefix(i + 1).joined(separator: "/")
            
            if (subPath.hasSuffix(".app") || subPath.hasSuffix(".xpc")),
               FileManager.default.fileExists(atPath: subPath) {
                return subPath
            }
        }
        
        return nil
    }
}
