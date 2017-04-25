import Foundation

struct Action {
    let command: Command
    let arguments: Arguments
}

extension Action: Equatable {
    static func == (lhs: Action, rhs: Action) -> Bool {
            return lhs.command == rhs.command &&
                lhs.arguments == rhs.arguments
    }
}
