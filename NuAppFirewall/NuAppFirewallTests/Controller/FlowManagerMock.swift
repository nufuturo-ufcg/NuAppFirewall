//
//  FlowManagerMock.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 07/11/24.
//

class FlowManagerMock {
    
    var rulesManager: RulesManager
    
    init(rulesManager: RulesManager) {
        self.rulesManager = rulesManager
    }

    public func handleNewFlow(flow: FlowMock) -> String {
        
        if let rule = rulesManager.getRule(bundleID: flow.app, appPath: flow.app, url: flow.url, host: flow.host, ip: flow.ip, port: flow.port) {
            let verdict = rule.action == TestConstants.actionBlock ? TestConstants.actionBlock : TestConstants.actionAllow
            
            return verdict
        } else {
            //Default Passive-Mode
            return Consts.verdictAllow;
        }
    }
}
