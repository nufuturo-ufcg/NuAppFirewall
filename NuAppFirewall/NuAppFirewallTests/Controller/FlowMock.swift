//
//  FlowMock.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 06/11/24.
//

import Foundation

class FlowMock {
    let url: String
    let host: String
    let ip: String
    let port: String
    let app: String
    
    init(url: String, host: String, ip: String, app: String, port: String) {
        self.url = url
        self.host = host
        self.ip = ip
        self.app = app
        self.port = port
    }
}
