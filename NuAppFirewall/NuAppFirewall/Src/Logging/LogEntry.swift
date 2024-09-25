/*
    File: LogEntry.swift
    Project: App Firewall (nufuturo.nuappfirewall)
    Description: LogEntry is a class that represents a single log entry in a network content filter.
 
    Created by com.nufuturo.nuappfirewall
*/

import Foundation

public class LogEntry {
    
    let category: String
    let flowID: String
    let process: String
    let endpoint: String
    
    init(category: String, flowID: String, process: String, endpoint: String) {
        self.category = category
        self.flowID = flowID
        self.process = process
        self.endpoint = endpoint
    }
    
    public func getRepresentation() -> String {
        return "CATEGORY=\(category), FLOW_ID=\(flowID), PROCESS=\(process), ENDPOINT=\(endpoint)"
    }

}
