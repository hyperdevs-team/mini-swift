//
//  Store.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation
import Combine
import SwiftUI

final public class Store<S: State>: BindableObject {
    
    public var didChange: CurrentValueSubject<S, Never>
    
    private var _initialState: S
    private var _state: S
    private let dispatcher: Dispatcher
    
    private(set) public var state: S {
        set {
            if !newValue.isEqual(to: state) {
                _state = newValue
                didChange.send(newValue)
            }
        }
        get {
            _state
        }
    }
    /**
     Property responsible of reduce the `State` given a certain `Action` being triggered.
    ```
     @DelayedImmutable public var reducerGroup: ReducerGroup {
        ReducerGroup {
         ActionReducer(dispatcher: dispatcher, action: SomeAction.self) { (action: SomeAction)
            self.state = myCoolNewState
         }
         ActionReducer(dispatcher: dispatcher, action: OtherAction.self) { (action: OtherAction)
            // Needed work
            self.state = myAnotherState
         }
        }
     }
    ```
     - Note : As the property being annotated with `@DelayedImmutable`, it is not required at initialization time, but it will crash if either the group is not defined but used or mutated once the group is defined.
     */
    @DelayedImmutable public var reducerGroup: ReducerGroup
    
    public var initialState: S {
        _initialState
    }
    
    public init(state: S,
                dispatcher: Dispatcher) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.didChange = CurrentValueSubject(state)
    }
    
    public func replayOnce() {
        didChange.send(state)
    }
    
    public func reset() {
        state = initialState
    }
}
