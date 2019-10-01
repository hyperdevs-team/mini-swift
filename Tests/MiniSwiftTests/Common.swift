import Foundation
import RxSwift
@testable import Mini

class SetCounterAction: Action {

    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

class SetCounterActionLoaded: Action {
    
    let counter: Promise<Int>
    
    init(counter: Promise<Int>) {
        self.counter = counter
    }
    
    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterActionLoaded else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

class SetCounterHashAction: Action {
    
    let counter: Int
    let key: String
    
    init(counter: Int, key: String) {
        self.counter = counter
        self.key = key
    }
    
    func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterHashAction else { return false }
        guard counter == action.counter else { return false }
        guard key == action.key else { return false }
        return true
    }
}

class SetCounterHashLoadedAction: KeyedCompletableAction {

    typealias Key = String
    typealias Payload = Int
    
    let promise: [Key: Promise<Payload>]
    
    required init(promise: [Key : Promise<Payload>]) {
        self.promise = promise
    }
    
    func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterHashLoadedAction else { return false }
        guard promise == action.promise else { return false }
        return true
    }
}

struct TestState: StateType {

    let counter: Promise<Int>
    let hashCounter: [String: Promise<Int>]

    init(counter: Promise<Int> = .idle(),
         hashCounter: [String: Promise<Int>] = [:]) {
        self.counter = counter
        self.hashCounter = hashCounter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        guard hashCounter == state.hashCounter else { return false }
        return true
    }
}

class TestStoreController: Disposable {
    
    let dispatcher: Dispatcher
    
    init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
    }
    
    func counter(_ number: Int) {
        self.dispatcher.dispatch(SetCounterActionLoaded(counter: .value(number)), mode: .async)
    }
    
    func hashCounter(counter: Int, key: String) {
        self.dispatcher.dispatch(SetCounterHashLoadedAction(promise: [key: .value(counter)]), mode: .async)
    }
    
    public func dispose() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        return ReducerGroup(
            Reducer(of: SetCounterAction.self, on: self.dispatcher) { action in
                guard !self.state.counter.isPending else { return }
                self.state = TestState(counter: .pending())
                self.storeController.counter(action.counter)
            },
            Reducer(of: SetCounterActionLoaded.self, on: self.dispatcher) { action in
                self.state.counter
                    .resolve(action.counter.result)?
                    .notify(to: self)
            },
            Reducer(of: SetCounterHashAction.self, on: self.dispatcher) { action in
                guard !(self.state.hashCounter[action.key]?.isPending ?? false) else { return }
                self.state = TestState(hashCounter: self.state.hashCounter.mergingNew(with: [action.key: .pending()]))
                self.storeController.hashCounter(counter: action.counter, key: action.key)
            },
            Reducer(of: SetCounterHashLoadedAction.self, on: self.dispatcher) { action in
                self.state = TestState(hashCounter: self.state.hashCounter.resolve(with: action.promise))
            }
        )
    }
}
