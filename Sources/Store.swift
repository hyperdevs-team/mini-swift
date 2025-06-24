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
                    stateCurrentValueSubject.send(state)
                    statePassthroughSubject.send(state)
                }
            }
        }
    }
    public var initialState: StoreState

    public init(_ state: StoreState,
                dispatcher: Dispatcher,
                storeController: StoreController,
                defaultPublisherMode: DefaultPublisherMode = .currentValue) {
        self.initialState = state
        self.dispatcher = dispatcher
        self.stateCurrentValueSubject = .init(state)
        self.statePassthroughSubject = .init()
        self.storeController = storeController
        self.state = state
        self.defaultPublisherMode = defaultPublisherMode
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
        stateCurrentValueSubject.send(state)
        statePassthroughSubject.send(state)

        dispatcher.stateWasReplayed(state: state)
    }

    public func reset() {
        state = initialState
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, StoreState == S.Input {
        publisher.receive(subscriber: subscriber)
    }

    public var publisher: StorePublisher {
        switch defaultPublisherMode {
        case .passthrough:
            return passthroughPublisher

        case .currentValue:
            return currentValuePublisher
        }
    }

    public var passthroughPublisher: StorePublisher {
        .init(subject: statePassthroughSubject)
    }

    public var currentValuePublisher: StorePublisher {
        .init(subject: stateCurrentValueSubject)
    }

    /// Scope a task from the state and receive only new updated since subscription.
    public func scope<T: Taskable & Equatable>(_ transform: @escaping (StoreState) -> T) -> AnyPublisher<T, Failure> {
        passthroughPublisher
            .map(transform)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var stateCurrentValueSubject: CurrentValueSubject<StoreState, Never>
    private var statePassthroughSubject: PassthroughSubject<StoreState, Never>
    private let queue = DispatchQueue(label: "atomic state")
    private let defaultPublisherMode: DefaultPublisherMode
}

public extension Store {
    enum DefaultPublisherMode {
        case passthrough
        case currentValue
    }

    class StorePublisher: Publisher {
        public typealias Output = StoreState
        public typealias Failure = Never

        private var subject: any Subject<StoreState, Never>

        internal init(subject: any Subject<StoreState, Never>) {
            self.subject = subject
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            subject.subscribe(subscriber)
        }
    }
}
