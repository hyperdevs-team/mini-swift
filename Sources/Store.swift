import Combine
import Foundation

public class Store<StoreState: State, StoreController: Cancellable>: Publisher {
    public typealias Output = StoreState
    public typealias Failure = Never
    public typealias StoreController = StoreController

    public let dispatcher: Dispatcher
    public var storeController: StoreController
    public var state: StoreState {
        get {
            _state
        }
        set {
            queue.sync {
                if newValue != _state {
                    _state = newValue
                    stateCurrentValueSubject.send(state)
                    statePassthroughSubject.send(state)
                }
            }
        }
    }
    public var initialState: StoreState {
        _initialState
    }

    public init(_ state: StoreState,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.stateCurrentValueSubject = .init(state)
        self.statePassthroughSubject = .init()
        self.storeController = storeController
        self.state = _initialState
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

    /// Exposes a passthrough publisher for the Store. 
    /// Doesn’t have an initial value or a buffer of the most recently-published state.
    public lazy var passthrough: PassthroughStorePublisher = {
        .init(statePassthroughSubject: statePassthroughSubject)
    }()

    public func replayOnce() {
        stateCurrentValueSubject.send(state)
        statePassthroughSubject.send(state)

        dispatcher.stateWasReplayed(state: state)
    }

    public func reset() {
        state = initialState
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        stateCurrentValueSubject.subscribe(subscriber)
    }

    private var stateCurrentValueSubject: CurrentValueSubject<StoreState, Never>
    private var statePassthroughSubject: PassthroughSubject<StoreState, Never>
    private let queue = DispatchQueue(label: "atomic state")
    private var _initialState: StoreState
    private var _state: StoreState
}

public extension Store {
    class PassthroughStorePublisher: Publisher {
        public typealias Output = StoreState
        public typealias Failure = Never

        private var statePassthroughSubject: PassthroughSubject<StoreState, Never>

        internal init(statePassthroughSubject: PassthroughSubject<StoreState, Never>) {
            self.statePassthroughSubject = statePassthroughSubject
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            statePassthroughSubject.subscribe(subscriber)
        }
    }
}
