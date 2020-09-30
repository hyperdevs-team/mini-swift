/*
 Copyright [2019] [BQ]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import RxSwift

public protocol StoreType {
    associatedtype State: StateType
    associatedtype StoreController: Disposable

    var state: State { get set }
    var dispatcher: Dispatcher { get }
    var reducerGroup: ReducerGroup { get }
}

extension StoreType {
    /**
     Property responsible of reduce the `State` given a certain `Action` being triggered.
     ```
     public var reducerGroup: ReducerGroup {
        ReducerGroup {[
            Reducer(of: SomeAction.self, on: self.dispatcher) { (action: SomeAction)
                self.state = myCoolNewState
            },
            Reducer(of: OtherAction.self, on: self.dispatcher) { (action: OtherAction)
                // Needed work
                self.state = myAnotherState
                }
            }
        ]}
     ```
     - Note : The property has a default implementation which complies with the @_functionBuilder's current limitations, where no empty blocks can be produced in this iteration.
     */
    public var reducerGroup: ReducerGroup {
        return ReducerGroup {
            []
        }
    }
}

public class Store<State: StateType, StoreController: Disposable>: ObservableType, StoreType {

    public typealias Element = State

    public typealias State = State
    public typealias StoreController = StoreController

    public typealias ObjectWillChangePublisher = BehaviorSubject<State>

    public var objectWillChange: ObjectWillChangePublisher

    private var _initialState: State
    public let dispatcher: Dispatcher
    public var storeController: StoreController

    private let queue = DispatchQueue(label: "atomic state")

    private var _state: State

    public var state: State {
        get {
            return _state
        }
        set {
            queue.sync {
                if !newValue.isEqual(to: _state) {
                    _state = newValue
                    objectWillChange.onNext(state)
                }
            }
        }
    }

    public var initialState: State {
        return _initialState
    }

    public init(_ state: State,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.objectWillChange = ObjectWillChangePublisher(value: state)
        self.storeController = storeController
        self.state = _initialState
    }

    public var reducerGroup: ReducerGroup {
        return ReducerGroup {
            []
        }
    }

    public func replayOnce() {
        objectWillChange.onNext(state)
    }

    public func reset() {
        state = initialState
    }

    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Store.Element {
        return objectWillChange.subscribe(observer)
    }
}
