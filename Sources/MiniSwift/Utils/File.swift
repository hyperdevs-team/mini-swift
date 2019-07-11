//
//  PayloadAction.swift
//  
//
//  Created by Jorge Revuelta on 11/07/2019.
//

import Foundation

protocol PayloadAction {
    associatedtype Payload

    init(task: Task, payload: Payload?)
}

protocol CompletableAction: Action & PayloadAction { }

protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never {
    init(task: Task)
}

extension EmptyAction {
    init(task: Task, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}

protocol KeyedPayloadAction {

    associatedtype Payload
    associatedtype Key: Hashable

    init(task: Task, payload: Payload?, key: Key)
}

protocol KeyedCompletableAction: Action & KeyedPayloadAction { }
