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
                    stateSubject.send(state)
                }
            }
        }
    }
    public var initialState: StoreState

    public init(_ state: StoreState,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self.initialState = state
        self.dispatcher = dispatcher
        self.stateSubject = .init(state)
        self.storeController = storeController
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
        stateSubject.send(state)

        dispatcher.stateWasReplayed(state: state)
    }

    public func reset() {
        state = initialState
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, StoreState == S.Input {
        publisher.receive(subscriber: subscriber)
    }

    public var publisher: Publishers.StoreStatePublisher<StoreState> {
        .init(upstream: stateSubject)
    }

    /// Scope a task from the state and receive only new updated since subscription.
    public func scope<T: Taskable>(_ transform: @escaping (StoreState) -> T) -> Publishers.StoreScopePublisher<T> {
        Publishers.StoreScopePublisher(upstream: stateSubject.map(transform),
                                       initialValue: transform(state))
    }

    private var stateSubject: CurrentValueSubject<StoreState, Never>
    private let queue = DispatchQueue(label: "atomic state")
}

public extension Publishers {
    class StoreStatePublisher<StoreState: State>: Publisher {
        public typealias Upstream = any Subject<StoreState, Never>
        public typealias Output = StoreState
        public typealias Failure = Never

        private let upstream: Upstream

        internal init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            upstream.subscribe(subscriber)
        }
    }

    struct StoreScopePublisher<StoreTask: Taskable>: Publisher {
        public typealias Upstream = any Publisher<StoreTask, Never>
        public typealias Output = StoreTask
        public typealias Failure = Never

        private let upstream: Upstream
        private let initialValue: StoreTask

        internal init(upstream: Upstream, initialValue: StoreTask) {
            self.upstream = upstream
            self.initialValue = initialValue
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            upstream.subscribe(Inner(downstream: subscriber, initialValue: initialValue))
        }
    }
}

extension Publishers.StoreScopePublisher {
    private class Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Never, Output == StoreTask {
        public typealias Input = Output
        public typealias Failure = Never

        let combineIdentifier = CombineIdentifier()
        private let downstream: Downstream
        private var lastValue: StoreTask

        fileprivate init(downstream: Downstream, initialValue: StoreTask) {
            self.downstream = downstream
            self.lastValue = initialValue
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Output) -> Subscribers.Demand {
            if input == lastValue {
                return .none
            }
            self.lastValue = input
            return downstream.receive(input)
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
