import Foundation

public extension Dictionary {
    /// Returns the value for the given key. If the key is not found in the map, calls the [defaultValue] function,
    /// puts its result into the map under the given key and returns it.
    mutating func safeValue(_ key: Key, defaultValue: () -> Value) -> Value {
        self[key, ifNotExistsSave: defaultValue()]
    }

    subscript (_ key: Key, ifNotExistsSave value: @autoclosure () -> Value) -> Value {
        mutating get {
            if let value = self[key] {
                return value
            }
            let value = value()
            self[key] = value
            return value
        }
    }
}
