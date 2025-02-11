/*
    File: SystemTestUtils.swift
    Project: NuAppFirewall (nufuturo.nuappfirewall)
    Description: SystemTestUtils provides utility functions for updating progress bars, printing detailed reports, 
        and managing atomic counters for thread-safe incrementing. 
        It helps in displaying real-time progress and generating formatted reports for URL validation results.

    Created by Walber Araujo on 01/02/2025
*/

import Foundation

func updateProgressBar(current: Int, total: Int) {
    let progress = Float(current) / Float(total)
    let barLength = 50
    let filledLength = Int(progress * Float(barLength))
    let bar = String(repeating: "=", count: filledLength) + String(repeating: "-", count: barLength - filledLength)
    let percent = Int(progress * 100)
    print("\r[\(bar)] \(percent)%", terminator: "")
    fflush(stdout)
}

func printReport(_ reports: [URLReport]) {
    let notFoundReports = reports.filter { !$0.logFound }
    let discrepancyReports = reports.filter { $0.expectedVerdict != $0.actualVerdict && $0.logFound }

    if notFoundReports.isEmpty && discrepancyReports.isEmpty {
        print("\(ANSIColor.green.rawValue)Test succeeded: Nenhuma discrepância encontrada.\(ANSIColor.reset.rawValue)")
    } else {
        if !notFoundReports.isEmpty {
            print("\(ANSIColor.yellow.rawValue)Alerta: Logs não encontrados para \(notFoundReports.count) URLs:\(ANSIColor.reset.rawValue)")
            notFoundReports.forEach { report in
                print("URL: \(report.url)")
            }
            print(String(repeating: "-", count: 50))
        }

        if !discrepancyReports.isEmpty {
            print("\(ANSIColor.red.rawValue)Test failed: Discrepâncias encontradas (\(discrepancyReports.count)).\(ANSIColor.reset.rawValue)")
            discrepancyReports.forEach { report in
                print("""
                    URL: \(report.url)
                    Esperado: \(report.expectedVerdict)
                    Resultado: \(report.actualVerdict)
                    """)
                print(String(repeating: "-", count: 50))
            }
        }
    }
}

class AtomicCounter {
    private let queue = DispatchQueue(label: "atomic.counter.queue")
    private var _value: Int = 0

    var value: Int { queue.sync { _value } }

    func increment() -> Int {
        queue.sync {
            _value += 1
            return _value
        }
    }
}