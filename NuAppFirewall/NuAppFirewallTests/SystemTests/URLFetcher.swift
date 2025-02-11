/*
    File: URLFetcher.swift
    Project: NuAppFirewall (nufuturo.nuappfirewall)
    Description: URLFetcher is a utility that performs network requests to verify URL accessibility.

    Created by Walber Araujo on 01/02/2025
*/

import Foundation

func fetchURL(_ url: String, port: String?, processPath: String?, identifier: String, expectedVerdict: String, timeout: TimeInterval, completion: @escaping (URLReport) -> Void) {
    let formattedURL = url.hasPrefix("http://") || url.hasPrefix("https://") ? url : "https://\(url)"
    guard let urlObj = URL(string: formattedURL) else {
        completion(URLReport(url: formattedURL, port: port, processPath: processPath, identifier: identifier, expectedVerdict: expectedVerdict, actualVerdict: "block", logFound: false))
        return
    }

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeout
    let session = URLSession(configuration: config)

    let task = session.dataTask(with: urlObj) { _, _, _ in
        let actualVerdict = fetchVerdictFromSyslog(for: formattedURL, port: port, processPath: processPath, identifier: identifier, expectedVerdict: expectedVerdict)
        let logFound = actualVerdict != "not found"
        completion(URLReport(url: formattedURL, port: port, processPath: processPath, identifier: identifier, expectedVerdict: expectedVerdict, actualVerdict: actualVerdict, logFound: logFound))
    }
    task.resume()
}