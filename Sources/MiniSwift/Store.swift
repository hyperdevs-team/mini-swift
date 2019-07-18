//
//  Store.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation
import Combine
import SwiftUI

public protocol StoreType {
    associatedtype State: StateType
    associatedtype StoreController: Cancellable

    var state: State { get set }
    var dispatcher: Dispatcher { get }
    var reducerGroup: ReducerGroup { get }
}

extension StoreType {
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
}

public class Store<State: StateType, StoreController: Cancellable>: BindableObject, StoreType {

    public typealias State = State
    public typealias StoreController = StoreController

    public var willChange: CurrentValueSubject<State, Never>

    private var _initialState: State
    public let dispatcher: Dispatcher
    private var storeController: StoreController

    @AtomicState public var state: State {
        didSet {
            willChange.send(state)
        }
    }

    public var initialState: State {
        _initialState
    }

    public init(_ state: State,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self._initialState = state
        self.dispatcher = dispatcher
        self.willChange = CurrentValueSubject(state)
        self.storeController = storeController
        self.state = _initialState
    }

    public var reducerGroup: ReducerGroup {
        ReducerGroup {
            CancellableBag()
        }
    }

    public func replayOnce() {
        willChange.send(state)
    }

    public func reset() {
        state = initialState
    }
}
