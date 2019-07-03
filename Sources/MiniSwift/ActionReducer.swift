//
//  ActionReducer.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation

public struct ActionReducer {
    public var action: Action.Type
    
    public var dispatcher: Dispatcher
    public var reducer: (Action) -> ()
    
    public init(dispatcher: Dispatcher, action: Action.Type, reducer: @escaping (Action) -> ()) {
        self.dispatcher = dispatcher
        self.action = action
        self.reducer = reducer
    }
}

