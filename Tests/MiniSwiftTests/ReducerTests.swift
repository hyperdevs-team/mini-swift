import XCTest
import RxSwift
import Nimble
@testable import MiniSwift

class SetCounterAction: Action {

    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

class SetCounterActionLoaded: Action {
    
    let counter: Int
    
    init(counter: Int) {
        self.counter = counter
    }
    
    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterActionLoaded else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

struct TestState: StateType {

    let counter: Promise<Int>

    init(counter: Promise<Int> = .idle()) {
        self.counter = counter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        return true
    }
}

class TestStoreController: Disposable {
    
    let dispatcher: Dispatcher
    
    init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
    }
    
    func counter(_ number: Int) {
        self.dispatcher.dispatch(SetCounterActionLoaded(counter: number), mode: .async)
    }
    
    public func dispose() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        return ReducerGroup { [
            Reducer(of: SetCounterAction.self, on: self.dispatcher) { action in
                guard !self.state.counter.isOnProgress else { return }
                self.state = TestState(counter: .pending())
                self.storeController.counter(action.counter)
            },
            Reducer(of: SetCounterActionLoaded.self, on: self.dispatcher) { action in
                self.state.counter
                    .fulfill(action.counter)
                    .notify(to: self)
            }
        ]
        }
    }
}

final class ReducerTests: XCTestCase {

    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        store
            .reducerGroup
            .disposed(by: dBag)
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 1),
            mode: .sync
        )
        expect(counter).toEventually(equal(1), timeout: 5.5, pollInterval: 0.2)
    }

    func test_no_subscribe_to_store_produces_no_changes() {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        XCTAssertTrue(store.state.counter.isIdle)
    }

    func test_subscribe_to_store_receive_actions() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        expect(counter).toEventually(equal(2), timeout: 5.5, pollInterval: 0.2)
    }
    
    func test_subscribe_to_store_receive_multiple_actions() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        expect(counter).toEventually(equal(2), timeout: 5.5, pollInterval: 0.2)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
    }

    func test_reset_state() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
        store.reset()
        XCTAssert(store.state.isEqual(to: initialState))
    }
    
    func test_state_received_in_store() throws {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
        dispatcher.dispatch(
            SetCounterAction(counter: 4),
            mode: .sync
        )
        expect(counter).toEventually(equal(4), timeout: 5.5, pollInterval: 0.2)
    }
}
