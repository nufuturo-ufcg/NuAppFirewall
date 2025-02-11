/*
    File: URLReport.swift
    Project: NuAppFirewall (nufuturo.nuappfirewall)
    Description: URLReport defines the data structure used to store the results of network access validations, 
        including URL details, expected and actual verdicts, and log verification status. 
        It also includes ProcessData to represent network rules associated with specific processes.

    Created by Walber Araujo on 01/02/2025
*/

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