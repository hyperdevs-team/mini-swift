import Foundation

public protocol StateType {
    func isEqual(to other: StateType) -> Bool
}

public extension StateType where Self: Equatable {
    func isEqual(to other: StateType) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
