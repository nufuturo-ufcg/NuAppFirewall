//
//  FilterControlProvider.swift
//  extension
//
//  Created by Winicius Allan on 22/08/24.
//

import Foundation
import NetworkExtension

class FilterDataProvider : NEFilterDataProvider {
    
    override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        filterlogger.log("starting filter")
        
//        let protocol = NENetworkRule
        let networkRule = NENetworkRule(remoteNetwork: nil, remotePrefix: 0, localNetwork: nil, localPrefix: 0, protocol: .any, direction: NETrafficDirection.any)
    
        let filterRule = NEFilterRule(networkRule: networkRule, action: .filterData)
        let filterSettings = NEFilterSettings(rules: [filterRule], defaultAction: .allow)
        
        apply(filterSettings) { error in
            if let error = error {
                print("error when applying filter settings", error.localizedDescription)
                return
            }
            
            print("filter settings applied")
        }
        
        completionHandler(nil)
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        filterlogger.log("logando nova conexão")
        
        filterlogger.log("logando evento: \(flow)");
        
        if let socketFlow = flow as? NEFilterSocketFlow,
            let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint {
            let host = remoteEndpoint.hostname
            filterlogger.log("host do evento: \(host)")
        }
            
            return NEFilterNewFlowVerdict.allow();
    }
}
