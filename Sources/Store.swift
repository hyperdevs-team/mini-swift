import Combine
import Foundation

public class Store<StoreState: State, StoreController: Cancellable>: Publisher {
    public typealias Output = StoreState
    public typealias Failure = Never
    public typealias StoreController = StoreController

    public let dispatcher: Dispatcher
    public var storeController: StoreController
    public var state: StoreState {
        didSet {
            queue.sync {
                if state != oldValue {
                    if emitsInitialValue {
                        stateCurrentValueSubject.send(state)
                    } else {
                        statePassthroughSubject.send(state)
                    }
                }
            }
        }
    }
    public var initialState: StoreState

    public init(_ state: StoreState,
                dispatcher: Dispatcher,
                storeController: StoreController,
                emitsInitialValue: Bool = true) {
        self.initialState = state
        self.dispatcher = dispatcher
        self.stateCurrentValueSubject = .init(state)
        self.statePassthroughSubject = .init()
        self.storeController = storeController
        self.emitsInitialValue = emitsInitialValue
        self.state = state
    }

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
        ReducerGroup {
            []
        }
    }

    public func replayOnce() {
        if emitsInitialValue {
            stateCurrentValueSubject.send(state)
        } else {
            statePassthroughSubject.send(state)
        }

        dispatcher.stateWasReplayed(state: state)
    }

    public func reset() {
        state = initialState
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        if emitsInitialValue {
            stateCurrentValueSubject.subscribe(subscriber)
        } else {
            statePassthroughSubject.subscribe(subscriber)
        }
    }

    private var stateCurrentValueSubject: CurrentValueSubject<StoreState, Never>
    private var statePassthroughSubject: PassthroughSubject<StoreState, Never>
    private let queue = DispatchQueue(label: "atomic state")
    private let emitsInitialValue: Bool
}
