//
//  FlowManagerMock.swift
//  NuAppFirewall
//
//  Created by Walber Filho on 07/11/24.
//

class FlowManagerMock {
    
    let rulesManager: RulesManager
    
    init(rulesManager: RulesManager) {
        self.rulesManager = rulesManager
    }

    public func handleNewFlow(flow: FlowMock) -> String {
        let path = flow.path
        let url = flow.url
        let host = flow.host
        let endpoint = flow.ip
        let port = flow.port
        
        if let rule = rulesManager.getRule(appPath: path, url: url, host: host, ip: endpoint, port: port) {
            let verdict = rule.action == Consts.verdictBlock ? Consts.verdictBlock : Consts.verdictAllow
            
            return verdict
        } else {
            //Default Passive-Mode
            return Consts.verdictAllow;
        }
    }
}
