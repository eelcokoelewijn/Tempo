import Foundation

enum Argument {
    case username
    case password
    case dateFrom
    case dateTo
    case url
}

struct Arguments {
    var items: [Argument: String] = [:]
    
    func get(_ argument: Argument) -> String {
        return items[argument] ?? ""
    }
    
    mutating func add(value: String, forArgument: Argument) {
        items[forArgument] = value
    }
    
    subscript(index: Argument) -> String {
        return items[index] ?? ""
    }
}

extension Arguments: Equatable {
    static func == (lhs: Arguments, rhs: Arguments) -> Bool {
        return lhs.items == rhs.items
    }
}
