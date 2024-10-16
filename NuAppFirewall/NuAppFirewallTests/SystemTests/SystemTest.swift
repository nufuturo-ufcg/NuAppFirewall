import Foundation

enum ANSIColor: String {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case reset = "\u{001B}[0;0m"
}

struct URLReport: Codable {
    let url: String
    let expectedVerdict: String
    let actualVerdict: String
}

struct ProcessData: Codable {
    let key: String
    let action: String
    let path: String
    let endpoints: [String]
    let direction: String
}

func loadURLs() -> [(String, String)] {
    let filePath = "./test-rules.json"
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Erro ao ler o arquivo \(filePath)")
        return []
    }
    
    let decoder = JSONDecoder()
    do {
        let rules = try decoder.decode([String: [ProcessData]].self, from: data)
        let ipRegex = #"^(https?://)?(\d{1,3}\.){3}\d{1,3}($|/)"#
        
        let urls = rules.values.flatMap { $0.flatMap { process in
            process.endpoints.map { ("https://\($0)", process.action) }
        }}.filter { url, _ in
            !url.matches(regex: ipRegex)
        }
        return urls
    } catch {
        print("Erro ao decodificar o JSON: \(error)")
        return []
    }
}

extension String {
    func matches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

func fetchURL(_ url: String, expectedVerdict: String, timeout: TimeInterval, completion: @escaping (URLReport) -> Void) {
    guard let urlObj = URL(string: url) else {
        completion(URLReport(url: url, expectedVerdict: expectedVerdict, actualVerdict: "blocked"))
        return
    }

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeout
    let session = URLSession(configuration: config)

    let task = session.dataTask(with: urlObj) { _, _, _ in
        let actualVerdict = fetchVerdictFromSyslog(for: url)
        completion(URLReport(url: url, expectedVerdict: expectedVerdict, actualVerdict: actualVerdict))
    }
    task.resume()
}

func fetchVerdictFromSyslog(for url: String) -> String {
    let searchTerm = extractSearchTerm(from: url)

    for _ in 1...5 {
        if let verdict = checkLog(searchTerm) {
            return verdict
        }
        sleep(1)
    }
    return "allow"  // Valor padrão se não encontrar nada nos logs
}

private func extractSearchTerm(from url: String) -> String {
    return URL(string: url)?.host?.components(separatedBy: ".").suffix(2).joined(separator: ".") ?? url
}

private func checkLog(_ searchTerm: String) -> String? {
    let logCommand = """
    log show --predicate 'eventMessage CONTAINS "\(searchTerm)" AND subsystem == "com.nufuturo.nuappfirewall.extension"' --info --last 2m
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

func processURLs(maxConcurrentConnections: Int = 16, timeout: TimeInterval = 3) {
    let urls = loadURLs()
    if urls.isEmpty { return print("Nenhuma URL para processar.") }

    print("Processando \(urls.count) URLs...")
    
    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: maxConcurrentConnections)
    var reports: [URLReport] = []
    let progressCounter = AtomicCounter()

    for (url, expectedVerdict) in urls {
        group.enter()
        semaphore.wait()

        DispatchQueue.global().async {
            fetchURL(url, expectedVerdict: expectedVerdict, timeout: timeout) { report in
                if report.expectedVerdict != report.actualVerdict {
                    DispatchQueue.global().sync {
                        reports.append(report)
                    }
                }

                let progress = progressCounter.increment()
                updateProgressBar(current: progress, total: urls.count)

                semaphore.signal()
                group.leave()
            }
            usleep(150_000)
        }
    }

    group.notify(queue: .main) {
        print("\nConcluído.")
        printReport(reports)
        exit(EXIT_SUCCESS)
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
    if reports.isEmpty {
        print("\(ANSIColor.green.rawValue)Test succeeded: Nenhuma discrepância encontrada.\(ANSIColor.reset.rawValue)")
    } else {
        print("\(ANSIColor.red.rawValue)Test failed: Discrepâncias encontradas (\(reports.count)).\(ANSIColor.reset.rawValue)")
        reports.forEach { report in
            print("""
                URL: \(report.url)
                Esperado: \(report.expectedVerdict)
                Resultado: \(report.actualVerdict)
                """)
            print(String(repeating: "-", count: 50))
        }
    }
}

processURLs()
RunLoop.main.run()

