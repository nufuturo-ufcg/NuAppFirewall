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
                LogManager.shared.logError(error: error)
                return
            }
            
            LogManager.shared.log("filter settings applied")
        }
        
        completionHandler(nil)
    }
    
    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        LogManager.shared.log("new network flow")
        
        LogManager.shared.log("new flow: \(flow)");
                
        if let socketFlow = flow as? NEFilterSocketFlow,
           let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint {
            let host = remoteEndpoint.hostname
            LogManager.shared.log("hostname: \(host)")
            
            let process = String(describing: socketFlow.sourceProcessAuditToken)
            let flowID = String(describing: socketFlow.identifier)
            
            LogManager.shared.logNewFlow(category: "connection", flowID: flowID, process: process, endpoint: String(describing: remoteEndpoint))
            
            if let url = flow.url?.absoluteString {
                LogManager.shared.log("url: \(url)")
                if url.contains("youtube.com") {
                    LogManager.shared.log("accessed youtube, blocking flow")
                    return .drop()
                }
            }
        }
            
            return NEFilterNewFlowVerdict.allow();
    }
}
