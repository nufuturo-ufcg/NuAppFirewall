import Foundation
import NetworkExtension

public class FilterDataProvider : NEFilterDataProvider {
    
    let facade = NuAppFacade()
    
    public override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        LogManager.logManager.log("starting filter")
        LogManager.logManager.log("starting filter", level: .debug, functionName: #function)
        
        let networkRule = NENetworkRule(remoteNetwork: nil, remotePrefix: 0, localNetwork: nil, localPrefix: 0, protocol: .any, direction: NETrafficDirection.any)
        
        let filterRule = NEFilterRule(networkRule: networkRule, action: .filterData)
        let filterSettings = NEFilterSettings(rules: [filterRule], defaultAction: .allow)
        
        apply(filterSettings) { error in
            if let error = error {
                LogManager.logManager.logError(error)
                return
            }
            
            LogManager.logManager.log("filter settings applied")
            LogManager.logManager.log("filter settings applied", level: .debug, functionName: #function)
        }
        
        completionHandler(nil)
    }
    
    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        LogManager.logManager.log("handling new flow", level: .debug, functionName: #function)
        
        return facade.handleNewFlow(flow)
    }
    
}
