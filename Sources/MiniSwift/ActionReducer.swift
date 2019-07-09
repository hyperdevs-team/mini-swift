//
//  ActionReducer.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

public struct ActionReducer {
    private var action: Action.Type

    private var dispatcher: Dispatcher
    private var reducer: (Action) -> Void

    private init(dispatcher: Dispatcher, action: Action.Type, reducer: @escaping (Action) -> Void) {
        self.dispatcher = dispatcher
        self.action = action
        self.reducer = reducer
    }

    public static func reduce(dispatcher: Dispatcher, action: Action.Type, reducer: @escaping (Action) -> Void) -> [Cancellable] {
        Self(dispatcher: dispatcher, action: action, reducer: reducer).build()
    }

    public func build() -> [Cancellable] {
        [
            self.dispatcher
                .subscribe(tag: self.action.tag) { self.reducer($0) }
        ]
    }
}
