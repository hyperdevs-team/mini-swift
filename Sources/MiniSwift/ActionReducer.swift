//
//  ActionReducer.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

public struct Reducer: Cancellable {
    public let action: Action.Type
    public let dispatcher: Dispatcher
    public let reducer: (Action) -> Void

    @DelayedImmutable private var cancellable: Cancellable

    public init(of action: Action.Type, on dispatcher: Dispatcher, reducer: @escaping (Action) -> Void) {
        self.action = action
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.cancellable = build()
    }

    private func build() -> Cancellable {
        let cancellable = dispatcher.subscribe(tag: action.tag) {
            self.reducer($0)
        }
        return cancellable
    }

    public func cancel() {
        cancellable.cancel()
    }
}

public struct MultiReducer: Cancellable {
    let children: [Cancellable]

    public func cancel() {
        children.forEach { $0.cancel() }
    }
}

@_functionBuilder
public struct ActionReducerBuilder {

    public static func buildBlock() -> Cancellable {
        MultiReducer(children: [])
    }

    public static func buildBlock(_ content: Cancellable) -> Cancellable {
        content
    }

    public static func buildBlock(_ content: Cancellable...) -> Cancellable {
        MultiReducer(children: content)
    }
}
