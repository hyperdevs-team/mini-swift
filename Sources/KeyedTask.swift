import Foundation

public typealias KeyedTask<K: Hashable> = [K: Task]

extension KeyedTask where Value: Task {
    public subscript(task key: Key) -> Value {
        return self[unwrapping: key]
    }

    public func hasValue(for key: Dictionary.Key) -> Bool {
        return self.keys.contains(key)
    }

    /// Returns true if the KeyedTask contains a task with given key and its running. If the key don't exists return false
    public func isRunning(key: Key) -> Bool {
        guard hasValue(for: key) else {
            return false
        }
        return self[unwrapping: key].isRunning
    }

    /// Returns true if the KeyedTask contains a task with given key and its recently succeded. If the key don't exists return false
    public func isRecentlySucceeded(key: Key) -> Bool {
        guard hasValue(for: key) else {
            return false
        }
        return self[unwrapping: key].isRecentlySucceeded
    }

    /// Returns true if the KeyedTask contains a task with given key and its terminal. If the key don't exists return false
    public func isTerminal(key: Key) -> Bool {
        guard hasValue(for: key) else {
            return false
        }
        return self[unwrapping: key].isTerminal
    }

    /// Returns true if the KeyedTask contains a task with given key and its succesful. If the key don't exists return false
    public func isSuccessful(key: Key) -> Bool {
        guard hasValue(for: key) else {
            return false
        }
        return self[unwrapping: key].isSuccessful
    }

    /// Returns true if the KeyedTask contains a task with given key and its failure. If the key don't exists return false
    public func isFailure(key: Key) -> Bool {
        guard hasValue(for: key) else {
            return false
        }
        return self[unwrapping: key].isFailure
    }
}
