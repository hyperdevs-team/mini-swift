//
//  PayloadAction.swift
//  
//
//  Created by Jorge Revuelta on 11/07/2019.
//

import Foundation

public protocol PayloadAction {
    associatedtype Payload

    init(task: Task, payload: Payload?)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never {
    init(task: Task)
}

extension EmptyAction {
    private init(task: Task, payload: Payload?) {
        fatalError("Never call this method from an EmptyAction")
    }
}

public protocol KeyedPayloadAction {

    associatedtype Payload
    associatedtype Key: Hashable

    init(task: Task, payload: Payload?, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }
