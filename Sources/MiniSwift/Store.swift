//
//  Store.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation
import Combine
import SwiftUI

public protocol ReducerGroupType {
    var reducerGroup: ReducerGroup { get }
}

public class Store<S: State>: BindableObject, ReducerGroupType {

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
     public var reducerGroup: ReducerGroup {
        ReducerGroup {
         Reducer(of: SomeAction.self, on: self.dispatcher) { (action: SomeAction)
            self.state = myCoolNewState
         }
         Reducer(of: OtherAction.self, on: self.dispatcher) { (action: OtherAction)
            // Needed work
            self.state = myAnotherState
         }
        }
     }
    ```
     - Note : The property has a default implementation which complies with the @_functionBuilder's current limitations, where no empty blocks can be produced in this iteration.
     */
    public var reducerGroup: ReducerGroup {
        ReducerGroup {
            CancellableBag()
        }
    }

    @DelayedImmutable private var _reducerGroup: ReducerGroup

    public var initialState: S {
        _initialState
    }

    public init(state: S,
                dispatcher: Dispatcher) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.didChange = CurrentValueSubject(state)
        self._reducerGroup = reducerGroup
    }

    public func replayOnce() {
        didChange.send(state)
    }

    public func reset() {
        state = initialState
    }
}
