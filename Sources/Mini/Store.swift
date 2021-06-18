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
import Combine

@available(iOS 13.0, *)
public protocol StoreType {
    associatedtype State: StateType
     associatedtype StoreController: Cancellable

    var state: State { get set }
    var dispatcher: Dispatcher { get }
    var reducerGroup: ReducerGroup { get }

    func replayOnce()
}

@available(iOS 13.0, *)
public protocol ObservableType: Publisher {}

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
        return ReducerGroup()
    }
}

@available(iOS 13.0, *)
public class Store<State: StateType, StoreController: Cancellable>: StoreType {

    
    public typealias Element = State

    public typealias State = State
    public typealias StoreController = StoreController

    public typealias ObjectWillChangePublisher = CurrentValueSubject<State, Never>

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
                    objectWillChange.send(state)
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
        _initialState = state
        _state = state
        self.dispatcher = dispatcher
        objectWillChange = ObjectWillChangePublisher(state)
        self.storeController = storeController
        self.state = _initialState
    }

    public var reducerGroup: ReducerGroup {
        return ReducerGroup()
    }

    public func notify() {
        replayOnce()
    }

    public func replayOnce() {
        objectWillChange.send(state)
    }

    public func reset() {
        state = initialState
    }

    /*
    public func subscribe<Subscriber: AnyPublisher>(_ observer: Subscriber) -> Cancellable where Subscriber == Store.Element {
        objectWillChange.sink(receiveValue: observer)
    }*/
}

/*
public extension Store {
    func replaying() -> AnyPublisher<Store.State, Error> {
        startWith(state)
    }
}*/

@available(iOS 13.0, *)
extension Store {
    
    public func dispatch<A: Action>(_ action: @autoclosure @escaping () -> A) -> AnyPublisher<Store.State, Never> {
        let action = action()
        dispatcher.dispatch(action, mode: .sync)
        return objectWillChange.eraseToAnyPublisher()
    }
/*
    public func withStateChanges<T>(in stateComponent: KeyPath<Element, T>) -> AnyPublisher<T, Error> {
        return CurrentValueSubject<T, Never>.mapKeypath(stateComponent).eraseToAnyPublisher()
    }*/
}
