import Foundation

public protocol Changeable { }

public extension Changeable {
    func changing(change: (inout Self) -> Void) -> Self {
        var a = self
        let mirror = Mirror(reflecting: self)
        if case mirror.displayStyle = Mirror.DisplayStyle.struct {
            change(&a)
            return a
        } else {
            fatalError("changing cannot be used on structs")
        }
    }
}
