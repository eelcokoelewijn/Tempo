import Foundation
import TempoKit
import App

func parse(arguments: [String]) -> Action {
    var args = Arguments()
    var cliArgs = arguments.dropFirst()
    
    guard cliArgs.count > 1 else {
        help()
        exit(1)
    }
    
    guard let command = Command(rawValue: cliArgs[1]) else {
        help()
        exit(2)
    }
    
    switch command {
    case .credentials:
        guard cliArgs.count > 3 else {
            help()
            exit(4)
        }
        args.add(value: cliArgs[2], forArgument: .username)
        args.add(value: cliArgs[3], forArgument: .password)
        args.add(value: cliArgs[4], forArgument: .url)
    case .worklogs:
        let yesterday = Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: Date())
        let dfrmt = DateFormatter()
        dfrmt.dateFormat = "yyyy-MM-dd"
        if arguments.count > 3 {
            args.add(value: cliArgs[2], forArgument: .dateFrom)
            args.add(value: cliArgs[3], forArgument: .dateTo)
        } else if arguments.count > 2 {
            args.add(value: cliArgs[2], forArgument: .dateFrom)
        } else if let d = yesterday {
            args.add(value: dfrmt.string(from: d), forArgument: .dateFrom)
        } else {
            help()
            exit(0)
        }
    }
    
    return Action(command: command, arguments: args)
}

func help() {
    print("No valid arguments specified\nUsage:\n-> tempo credentials username password url\n-> tempo worklogs dateFrom? dateTo?\n(Date format: yyyy-MM-dd)")
}

class MainProcess {
    var shouldExit: Bool = false
    let credentialService = MixinCredentialService()
    
    func start(_ action: Action) {
        switch action.command {
        case .credentials:
            store(action)
        case .worklogs:
            worklogs(action)
            return
        }
    }

    private func store(_ action: Action) {
        let credentials = JIRACredentials(username: action.arguments[.username], password: action.arguments[.password])
        let url = URL(string: action.arguments[.url])!
        let config = JIRAConfig(url: url, credentials: credentials)
        credentialService.save(config: config) {
            print("done 🏁")
            self.shouldExit = true
        }
    }
    
    private func worklogs(_ action: Action) {
        let networkService = MixinNetworkService()
        credentialService.load() { [unowned self] config in
            let tempo = MixinTempoKit(networkService: networkService, config: config)
            
            print(self.title(args: action.arguments))
            tempo.worklogs(dateFrom: action.arguments[.dateFrom], dateTo: action.arguments[.dateTo]) { logs in
                DispatchQueue.main.async {
                    print(self.report(items: logs, withFormat: .text))
                    self.shouldExit = true
                }
            }
        }
    }
    
    private func title(args: Arguments) -> String {
        if !args[.dateFrom].isEmpty && !args[.dateTo].isEmpty {
            return "Worklogs from \(args[.dateFrom]) till \(args[.dateTo]) 🦄"
        } else if !args[.dateFrom].isEmpty {
            return "Worklogs from \(args[.dateFrom]) 👌"
        } else {
            return "W😀rkl🤠gs"
        }
    }
    
    private func report(items: [WorklogBean], withFormat format: LogFormat) -> String {
        switch format {
        case .text:
            let text = items.map { log in
                "\(log.comment)(\(log.issue.key))"
            }
            return text.joined(separator: "\n")
        case .markdown:
            let md = items.map { log in
                "### \(log.issue.key) - \(log.issue.summary)\n\(log.comment)"
            }
            return md.joined(separator: "\n")
        }
    }
}

enum LogFormat {
    case markdown
    case text
}

var runLoop: RunLoop = RunLoop.current
var process: MainProcess = MainProcess()

autoreleasepool {
    
    let cmdArgs = CommandLine.arguments
    let action = parse(arguments: cmdArgs)
    
    process.start(action)
    
    while (!process.shouldExit && (runLoop.run(mode: .defaultRunLoopMode, before: Date.distantFuture))) {
        // do nothing
    }
}

