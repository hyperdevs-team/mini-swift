import Foundation

public typealias KeyedTask<Key: Hashable, TaskPayload: Equatable, TaskError: Error & Equatable> = [Key: Task<TaskPayload, TaskError>]
public typealias KeyedEmptyTask<Key: Hashable, TaskError: Error & Equatable> = KeyedTask<Key, None, TaskError>

extension KeyedTask where Key: Hashable, Value: TaskType {
    public subscript(task key: Key) -> Value? {
        self[key]
    }

    public func hasValue(for key: Dictionary.Key) -> Bool {
        self.keys.contains(key)
    }

    /// Returns true if the KeyedTask contains a task with given key and its running. If the key don't exists return false
    public func isIdle(key: Key) -> Bool {
        self[key]?.isIdle ?? false
    }

    /// Returns true if the KeyedTask contains a task with given key and its running. If the key don't exists return false
    public func isRunning(key: Key) -> Bool {
        self[key]?.isRunning ?? false
    }

    /// Returns true if the KeyedTask contains a task with given key and its recently succeded. If the key don't exists return false
    public func isRecentlySucceeded(key: Key) -> Bool {
        self[key]?.isRecentlySucceeded ?? false
    }

    /// Returns true if the KeyedTask contains a task with given key and its terminal. If the key don't exists return false
    public func isTerminal(key: Key) -> Bool {
        self[key]?.isTerminal ?? false
    }

    /// Returns true if the KeyedTask contains a task with given key and its succesful. If the key don't exists return false
    public func isSuccessful(key: Key) -> Bool {
        self[key]?.isSuccessful ?? false
    }

    /// Returns true if the KeyedTask contains a task with given key and its failure. If the key don't exists return false
    public func isFailure(key: Key) -> Bool {
        self[key]?.isFailure ?? false
    }
}
