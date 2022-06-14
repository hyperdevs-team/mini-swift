import Combine
@testable import Mini
import RxSwift
import XCTest

class OneTestAction: Action {
    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? OneTestAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

struct TestState: StateType {
    public let testTask: TypedTask<None>
    public let counter: Int

    public init(testTask: TypedTask<None> = .requestIdle(), counter: Int = 0) {
        self.testTask = testTask
        self.counter = counter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        return true
    }
}

class TestStoreController: Disposable {
    public func dispose() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {
    func reducerGroup(expectation: XCTestExpectation? = nil) -> ReducerGroup {
        ReducerGroup { [
            Reducer(of: OneTestAction.self, on: self.dispatcher) { action in
                self.state = TestState(testTask: .requestSuccess(), counter: action.counter)
                expectation?.fulfill()
            }
        ]
        }
    }
}

final class ReducerTests: XCTestCase {
    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .disposed(by: dBag)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(OneTestAction(counter: 1))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 1)
    }

    func test_no_subscribe_to_store_produces_no_changes() {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(OneTestAction(counter: 2))

        XCTAssertTrue(store.state.counter == 0)
    }

    func test_subscribe_to_store_receive_actions() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .disposed(by: dBag)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(OneTestAction(counter: 2))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 2)
    }

    func test_reset_state() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .disposed(by: dBag)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(OneTestAction(counter: 3))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 3)

        store.reset()
        XCTAssert(store.state.isEqual(to: initialState))
    }

    func test_subscribe_state_changes_with_rx() {
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Subscription Emits 1")

        store
            .reducerGroup()
            .disposed(by: dBag)
        store
            .map { $0.counter }
            .subscribe(onNext: { counter in
                if counter == 1 {
                    expectation.fulfill()
                }
            })
            .disposed(by: dBag)

        dispatcher.dispatch(OneTestAction(counter: 1))
        wait(for: [expectation], timeout: 5.0)
    }

    func test_subscribe_state_changes_with_combine() {
        let dBag = DisposeBag()
        var bag = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation1 = XCTestExpectation(description: "Subscription Emits 1")
        let expectation2 = XCTestExpectation(description: "Subscription Emits 2")

        store
            .reducerGroup()
            .disposed(by: dBag)
        store
            .map(\.counter)
            .sink { counter in
                if counter == 1 {
                    expectation1.fulfill()
                }
                if counter == 2 {
                    expectation2.fulfill()
                }
            }
            .store(in: &bag)

        dispatcher.dispatch(OneTestAction(counter: 1))
        dispatcher.dispatch(OneTestAction(counter: 2))
        wait(for: [expectation1, expectation2], timeout: 5.0)
    }
}
