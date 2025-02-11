/*
    File: SystemTest.swift
    Project: NuAppFirewall (nufuturo.nuappfirewall)
    Description: SystemTest is a module designed to process multiple URLs concurrently, 
        verifying their accessibility and logging results. 
        It manages network requests with controlled concurrency, tracks progress, 
        and generates a comprehensive report of the system's network behavior.

    Created by Walber Araujo on 01/02/2025
*/

import Foundation

func processURLs(maxConcurrentConnections: Int = 4, timeout: TimeInterval = 2) {
    let urls = loadURLs(from: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "./controlled-rules.json")
    if urls.isEmpty { return print("Nenhuma URL para processar.") }

    print("Processando \(urls.count) URLs...")

    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: maxConcurrentConnections)
    var reports: [URLReport] = []
    let progressCounter = AtomicCounter()

    for (url, expectedVerdict, processPath, port, identifier) in urls {
        group.enter()
        semaphore.wait()

        DispatchQueue.global().async {
            fetchURL(url, port: port, processPath: processPath, identifier: identifier, expectedVerdict: expectedVerdict, timeout: timeout) { report in
                DispatchQueue.global().sync {
                    reports.append(report)
                }

                let progress = progressCounter.increment()
                updateProgressBar(current: progress, total: urls.count)

                semaphore.signal()
                group.leave()
            }
            usleep(200_000)
        }
    }

    group.notify(queue: .main) {
        print("\nConcluído.")
        printReport(reports)
        exit(EXIT_SUCCESS)
    }
}

processURLs()
RunLoop.main.run()