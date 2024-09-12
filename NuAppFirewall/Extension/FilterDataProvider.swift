//
//  FilterControlProvider.swift
//  extension
//
//  Created by Winicius Allan on 22/08/24.
//

import Foundation
import NetworkExtension
import OSLog

class FilterDataProvider : NEFilterDataProvider {
    
    let logger = Logger(subsystem: "com.nufuturo.nuappfirewall", category: "extension");
    
    override func startFilter(completionHandler: @escaping ((any Error)?) -> Void) {
        print("starting filter")
        
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
        print("logando nova conexão")
        
        logger.info("logando evento: \(flow)");
        return NEFilterNewFlowVerdict.allow();
    }
}
