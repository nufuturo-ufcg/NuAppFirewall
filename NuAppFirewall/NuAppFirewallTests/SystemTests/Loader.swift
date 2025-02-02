//
//  Loader.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 01/02/25.
//

import Foundation

func loadURLs(from filePath: String) -> [(String, String, String?, String?, String)] {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Erro ao ler o arquivo \(filePath)")
        return []
    }

    let decoder = JSONDecoder()
    do {
        let rules = try decoder.decode([String: [ProcessData]].self, from: data)
        let urls: [(String, String, String?, String?, String)] = rules.flatMap { processPath, processes in
            processes.flatMap { process -> [(String, String, String?, String?, String)] in
                process.destinations.compactMap { destination -> (String, String, String?, String?, String)? in
                    guard destination.count >= 2 else { return nil }
                    let url = destination[0]
                    let port = destination[1] == "any" ? nil : destination[1]
                    return (url, process.action, processPath, port, process.identifier)
                }
            }
        }
        return urls
    } catch {
        print("Erro ao decodificar o JSON: \(error)")
        return []
    }
}