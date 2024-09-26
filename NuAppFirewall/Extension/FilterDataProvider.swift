import Foundation
import NetworkExtension

public class FilterDataProvider : NEFilterDataProvider {
    
    public override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        LogManager.shared.log("starting filter")
        
        let networkRule = NENetworkRule(remoteNetwork: nil, remotePrefix: 0, localNetwork: nil, localPrefix: 0, protocol: .any, direction: NETrafficDirection.any)
        
        let filterRule = NEFilterRule(networkRule: networkRule, action: .filterData)
        let filterSettings = NEFilterSettings(rules: [filterRule], defaultAction: .allow)
        
        apply(filterSettings) { error in
            if let error = error {
                LogManager.shared.logError(error)
                return
            }
            
            LogManager.shared.log("filter settings applied")
        }
        
        completionHandler(nil)
    }
    
    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        LogManager.shared.log("new network flow")
        
        let (flowID, endpoint, auditToken) = extractLogInfo(from: flow)
        
        LogManager.shared.logNewFlow(category: "connection", flowID: flowID, auditToken: auditToken, endpoint: endpoint)
        
        if let url = flow.url?.absoluteString {
            LogManager.shared.log("url: \(url)")
            if url.contains("youtube.com") {
                LogManager.shared.log("accessed youtube, blocking flow")
                return .drop()
            }
        }
        
        return NEFilterNewFlowVerdict.allow();
    }
    
    private func extractLogInfo(from flow: NEFilterFlow) -> (UUID, String, audit_token_t) {
        let flowID = flow.identifier
        
        var endpoint = "Unknown"
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
        
        return (flowID, endpoint, auditToken)
    }
}
