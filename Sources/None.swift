import Foundation

public struct None: Equatable {
    internal init() {
    }

    public static var none: None {
        None()
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
