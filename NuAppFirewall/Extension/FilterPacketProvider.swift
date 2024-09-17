//
//  FilterPacketProvider.swift
//  extension
//
//  Created by Winicius Allan on 22/08/24.
//

import NetworkExtension

class FilterPacketProvider: NEFilterControlProvider {
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        
        packetHandler = { (context, interface, direction, packetBytes, packetLength) in
            return .allow
        }
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
        // Add code here to tear down the filter
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        
        
    }

}
