//
//  NuAppFacade.swift
//  Extension
//
//  Created by ec2-user on 07/10/2024.
//

import Foundation
import SystemExtensions
import NetworkExtension

public class NuAppFacade {
    
    let flowManager = FlowManager()
    
    func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        print("entrando no app facade para lidar com o flow")
        return flowManager.handleNewFlow(flow);
    }
}
