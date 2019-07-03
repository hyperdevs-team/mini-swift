//
//  File.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

public protocol Group {
    var cancellables: [DispatcherSubscription] { get set }
}

public struct ReducerGroup: Group {
    public var cancellables: [DispatcherSubscription]
    
    init(@ActionReducerBuilder builder: () -> [DispatcherSubscription]) {
        self.cancellables = builder()
    }
}

@_functionBuilder
public final class ActionReducerBuilder {

    public static func buildBlock(_ reducers: ActionReducer...) -> [DispatcherSubscription] {
        reducers
            .compactMap { reducer in
                reducer.dispatcher.subscribe(tag: reducer.action.tag) { reducer.reducer($0) }
        }
    }
}
