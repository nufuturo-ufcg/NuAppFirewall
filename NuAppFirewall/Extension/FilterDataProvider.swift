//
//  FilterControlProvider.swift
//  extension
//
//  Created by Winicius Allan on 22/08/24.
//

import Foundation
import NetworkExtension

public class FilterDataProvider : NEFilterDataProvider {
    
    public override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        filterlogger.log("starting filter")
        
        let networkRule = NENetworkRule(remoteNetwork: nil, remotePrefix: 0, localNetwork: nil, localPrefix: 0, protocol: .any, direction: NETrafficDirection.any)
    
        let filterRule = NEFilterRule(networkRule: networkRule, action: .filterData)
        let filterSettings = NEFilterSettings(rules: [filterRule], defaultAction: .allow)
        
        apply(filterSettings) { error in
            if let error = error {
                filterlogger.log("error when applying filter settings")
                return
            }
            
            filterlogger.log("filter settings applied")
        }
        
        completionHandler(nil)
    }
    
    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        filterlogger.log("new network flow")
        
        filterlogger.log("new flow: \(flow)");
        
        if let socketFlow = flow as? NEFilterSocketFlow,
           let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint {
            let host = remoteEndpoint.hostname
            filterlogger.log("hostname: \(host)")
            
            if let url = flow.url?.absoluteString {
                filterlogger.log("url: \(url)")
                if url.contains("youtube.com") {
                    filterlogger.log("accessed youtube, blocking flow")
                    return .drop()
                }
            }
        }
            
            return NEFilterNewFlowVerdict.allow();
    }
}
