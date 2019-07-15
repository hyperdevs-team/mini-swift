//
//  ActionReducer.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

public class Reducer<A: Action>: Cancellable {
    public let action: A.Type
    public let dispatcher: Dispatcher
    public let reducer: (A) -> Void

    @DelayedImmutable private var cancellable: Cancellable

    public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void) {
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
