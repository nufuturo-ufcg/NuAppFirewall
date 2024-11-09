//
//  FlowMock.swift
//  NuAppFirewall
//
//  Created by Walber Filho on 06/11/24.
//

import Foundation

class FlowMock {
    let url: String
    let host: String
    let ip: String
    let port: String
    let path: String
    
    init(url: String, host: String, ip: String, path: String, port: String) {
        self.url = url
        self.host = host
        self.ip = ip
        self.port = port
        self.path = path
    }
}
