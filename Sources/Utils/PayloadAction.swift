import Foundation

public protocol PayloadAction {
    associatedtype Payload

    init(task: TypedTask<Payload>, payload: Payload?)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == None {
    init(task: TypedTask<Payload>)
}

public extension EmptyAction {
    init(task: TypedTask<Payload>, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}

public protocol KeyedPayloadAction {
    associatedtype Payload
    associatedtype Key: Hashable

    init(task: TypedTask<Payload>, payload: Payload?, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & PayloadAction where Payload == None {
    associatedtype Key: Equatable

    init(task: TypedTask<Payload>, key: Key)
}

public extension KeyedEmptyAction {
    init(task: TypedTask<Payload>, payload: Payload?) {
        fatalError("Never call this method from a KeyedEmptyAction")
    }
}
