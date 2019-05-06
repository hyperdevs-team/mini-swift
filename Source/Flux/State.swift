import Foundation

/// Represents a State of a Store.
public protocol State: Changeable {
    func isEqualTo(_ other: State) -> Bool
}

public extension State where Self: Equatable {
    func isEqualTo(_ other: State) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

public extension State {
    var innerTag: String {
        return String(describing: type(of: self))
    }
}
