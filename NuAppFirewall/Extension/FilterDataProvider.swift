import Foundation
import NetworkExtension

public class FilterDataProvider : NEFilterDataProvider {
    
    public override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        LogManager.logManager.log("starting filter")
        
        let networkRule = NENetworkRule(remoteNetwork: nil, remotePrefix: 0, localNetwork: nil, localPrefix: 0, protocol: .any, direction: NETrafficDirection.any)
        
        let filterRule = NEFilterRule(networkRule: networkRule, action: .filterData)
        let filterSettings = NEFilterSettings(rules: [filterRule], defaultAction: .allow)
        
        apply(filterSettings) { error in
            if let error = error {
                LogManager.logManager.logError(error)
                return
            }
            
            LogManager.logManager.log("filter settings applied")
        }
        
        completionHandler(nil)
    }
    
    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        LogManager.logManager.log("new network flow")
        
        let (flowID, endpoint, url, auditToken) = extractLogInfo(from: flow)
        
        LogManager.logManager.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint, url: url)
            
        if url.contains("youtube.com") {
            LogManager.logManager.log("accessed youtube, blocking flow")
            return .drop()
        }
        
        return NEFilterNewFlowVerdict.allow();
    }
    
    private func extractLogInfo(from flow: NEFilterFlow) -> (UUID, String, String, audit_token_t) {
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
