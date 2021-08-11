import Foundation

public protocol PayloadAction {
    associatedtype Payload

    init(task: Task, payload: Payload?)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never {
    init(task: Task)
}

public extension EmptyAction {
    init(task: Task, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}

public protocol KeyedPayloadAction {
    associatedtype Payload
    associatedtype Key: Hashable

    init(task: Task, payload: Payload?, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & PayloadAction where Payload == Swift.Never {
    associatedtype Key: Hashable

    init(task: Task, key: Key)
}

public extension KeyedEmptyAction {
    init(task: Task, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}
