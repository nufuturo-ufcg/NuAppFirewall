//
//  TestDataFactory.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 25/01/25.
//

class TestDataFactory {
    
    static func generateRuleData(
        apps: [String] = [TestConstants.appPath, TestConstants.appSubpath, TestConstants.bundleID],
        endpoints: [String] = [Consts.any, TestConstants.url, TestConstants.host, TestConstants.ip],
        actions: [String] = [Consts.verdictAllow, Consts.verdictBlock],
        ports: [String] = [Consts.any, TestConstants.port]
    ) -> [RuleData] {
        var ruleData: [RuleData] = []
        
        for app in apps {
            for endpoint in endpoints {
                for portValue in ports {
                    for action in actions {
                        ruleData.append(RuleData(action: action, app: app, endpoint: endpoint, port: portValue))
                    }
                }
            }
        }
        
        return ruleData
    }
    
    static func generateFlowData(
        urls: [String] = [TestConstants.url, TestConstants.unknown],
        hosts: [String] = [TestConstants.host, TestConstants.unknown],
        ips: [String] = [TestConstants.ip, TestConstants.unknown],
        ports: [String] = [TestConstants.port, TestConstants.unknown],
        applications: [String] = [TestConstants.appPath, TestConstants.bundleID, TestConstants.unknown]
    ) -> [FlowData] {
        var flowData: [FlowData] = []
        
        for url in urls {
            for host in hosts {
                for ip in ips {
                    for port in ports {
                        for application in applications {
                            flowData.append(FlowData(url: url, host: host, ip: ip, port: port, app: application))
                        }
                    }
                }
            }
        }
        
        return flowData
    }
    
    static func createRule(action: String, app: String, endpoint: String, port: String) -> Rule? {
        let destination = "\(endpoint):\(port)"
        let ruleID = "\(app)-\(action)-\(destination)"
        
        return Rule(ruleID: ruleID, action: action, app: app, endpoint: endpoint, port: port) ?? nil
    }
}
