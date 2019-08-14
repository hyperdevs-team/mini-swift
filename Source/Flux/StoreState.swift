import Foundation

public protocol StoreState: Changeable {
    func isEqualTo(_ other: StoreState) -> Bool
}

public extension StoreState where Self: Equatable {
    func isEqualTo(_ other: StoreState) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

public extension StoreState {
    var innerTag: String {
        return String(describing: type(of: self))
    }
}
