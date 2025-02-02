//
//  URLReport.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 01/02/25.
//

import Foundation

struct URLReport: Codable {
    let url: String
    let port: String?
    let processPath: String?
    let identifier: String
    let expectedVerdict: String
    let actualVerdict: String
    let logFound: Bool
}

struct ProcessData: Codable {
    let action: String
    let identifier: String
    let destinations: [[String]]
}