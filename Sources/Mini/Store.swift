/*
 Copyright [2021] [Hyperdevs]
 
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

import Combine
import Foundation

public protocol StoreType: ObservableObject {
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

 
public class Store<State: StateType, StoreController: Cancellable>: StoreType {

    public typealias State = State
    public typealias StoreController = StoreController

    public let dispatcher: Dispatcher
    public var storeController: StoreController
    @Published public var state: State
    
    public var reducerGroup: ReducerGroup {
        return ReducerGroup()
    }

    public init(state: State,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self.dispatcher = dispatcher
        self.state = state
        self.storeController = storeController
    }
}

