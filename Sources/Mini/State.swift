/**
 Protocol that has to be conformed by any stete object
 by a `State` object.
 */
import Foundation

@objc public protocol StateType {
    @objc optional func isEqual(to other: StateType) -> Bool
}

public extension StateType where Self: Equatable {
    func isEqual(to other: StateType) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
