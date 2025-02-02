//
//  Logger.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 01/02/25.
//

import Foundation

func fetchVerdictFromSyslog(for url: String, port: String?, processPath: String?, identifier: String, expectedVerdict: String) -> String {
    let searchTerm = url.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
    let attemptCount = 5
    let delayBetweenAttempts: UInt32 = 2

    for attempt in 1...attemptCount {
        if let verdict = checkLog(searchTerm, port: port, processPath: processPath, identifier: identifier, expectedVerdict: expectedVerdict) {
            return verdict
        }
        if attempt < attemptCount {
            sleep(delayBetweenAttempts)
        }
    }
    return "not found"
}

private func checkLog(_ searchTerm: String, port: String?, processPath: String?, identifier: String, expectedVerdict: String) -> String? {
    let ruleIdPrefix = "\(identifier)-"
    let predicate = "eventMessage CONTAINS \"RULE_ID=\(ruleIdPrefix)\" AND eventMessage CONTAINS \"\(searchTerm):\(port ?? "any")\""

    let logCommand = """
    log show --predicate '\(predicate) AND subsystem == "com.nufuturo.nuappfirewall.extension"' --info --last 10s
    """

    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", logCommand]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let logOutput = String(data: data, encoding: .utf8) else { return nil }

    for line in logOutput.split(separator: "\n").reversed() {
        if line.contains("allow") { return "allow" }
        if line.contains("block") { return "block" }
    }
    return nil
}