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
        LogManager.logManager.log("entrando no flow manager para lidar com o flow")
        
        let url = flow.url?.absoluteString ?? "unknown"
        
        LogManager.logManager.log(url)
        
        if url.contains("youtube.com") {
            LogManager.logManager.log("accessed youtube, blocking flow")
            return .drop()
        }
        return NEFilterNewFlowVerdict.allow();
    }
}
