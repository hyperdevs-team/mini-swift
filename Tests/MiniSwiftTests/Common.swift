import Foundation
@testable import Mini
@testable import Promise
import RxSwift

struct SetCounterAction: Action {
    let counter: Int
}

struct SetCounterActionLoaded: Action {
    let counter: Promise<Int>
}

struct SetCounterHashAction: Action {
    let counter: Int
    let key: String
}

struct SetCounterHashLoadedAction: KeyedCompletableAction {
    typealias Key = String
    typealias Payload = Int

    let promise: [Key: Promise<Payload>]
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
        dispatcher.dispatch(SetCounterActionLoaded(counter: .value(number)), mode: .async)
    }

    func hashCounter(counter: Int, key: String) {
        dispatcher.dispatch(SetCounterHashLoadedAction(promise: [key: .value(counter)]), mode: .async)
    }

    public func dispose() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {
    var reducerGroup: ReducerGroup {
        return ReducerGroup(
            Reducer(of: SetCounterAction.self, on: dispatcher) { action in
                guard !self.state.counter.isPending else { return }
                self.state = TestState(counter: .pending())
                self.storeController.counter(action.counter)
            },
            Reducer(of: SetCounterActionLoaded.self, on: dispatcher) { action in
                self.state.counter
                    .resolve(action.counter.result)?
                    .notify(to: self)
            },
            Reducer(of: SetCounterHashAction.self, on: dispatcher) { action in
                guard !(self.state.hashCounter[action.key]?.isPending ?? false) else { return }
                self.state = TestState(hashCounter: self.state.hashCounter.mergingNew(with: [action.key: .pending()]))
                self.storeController.hashCounter(counter: action.counter, key: action.key)
            },
            Reducer(of: SetCounterHashLoadedAction.self, on: dispatcher) { action in
                self.state = TestState(hashCounter: self.state.hashCounter.resolve(with: action.promise))
            }
        )
    }
}
