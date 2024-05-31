import Combine
@testable import Mini
import XCTest

final class ReducerTests: XCTestCase {
    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .store(in: &cancellables)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(TestAction(counter: 1))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 1)
    }

    func test_no_subscribe_to_store_produces_no_changes() {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(TestAction(counter: 2))

        XCTAssertTrue(store.state.counter == 0)
    }

    func test_subscribe_to_store_receive_actions() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .store(in: &cancellables)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(TestAction(counter: 2))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 2)
    }

    func test_reset_state() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation = XCTestExpectation(description: "Reducer")
        store
            .reducerGroup(expectation: expectation)
            .store(in: &cancellables)

        XCTAssertTrue(store.state.counter == 0)

        dispatcher.dispatch(TestAction(counter: 3))
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(store.state.counter == 3)

        store.reset()
        XCTAssertEqual(store.state, initialState)
    }

    func test_subscribe_state_changes() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation1 = XCTestExpectation(description: "Subscription Emits 1")
        let expectation2 = XCTestExpectation(description: "Subscription Emits 2")

        store
            .reducerGroup()
            .store(in: &cancellables)

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
            .store(in: &cancellables)

        dispatcher.dispatch(TestAction(counter: 1))
        dispatcher.dispatch(TestAction(counter: 2))
        wait(for: [expectation1, expectation2], timeout: 5.0)
    }

    func test_subscribe_state_changes_without_initial_value() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController(), emitsInitialValue: false)
        let expectation = XCTestExpectation(description: "Subscription Emits")

        store
            .reducerGroup()
            .store(in: &cancellables)

        dispatcher.dispatch(TestAction(counter: 1))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Only gets the action with counter == 2.
            store
                .map(\.counter)
                .sink { counter in
                    if counter == 1 {
                        XCTFail("counter == 1 should not be emmited because this is a stateless subscription")
                    }
                    if counter == 2 {
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            // Send action with counter == 2, this action should be caught by the two subscriptions
            dispatcher.dispatch(TestAction(counter: 2))
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func test_scope() {
        var cancellables = Set<AnyCancellable>()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let expectation1 = XCTestExpectation(description: "Subscription Emits 1")

        store
            .reducerGroup()
            .store(in: &cancellables)

        dispatcher.dispatch(TestAction(counter: 1))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            store
                .scope { $0.testTask }
                .sink { task in
                    XCTAssertEqual(task.payload, 2) // Only get 2 because we scope the suscription to task
                                                    // on the state and receive non expired and unique values.
                    expectation1.fulfill()
                }
                .store(in: &cancellables)

            dispatcher.dispatch(TestAction(counter: 2))
        }

        wait(for: [expectation1], timeout: 5.0)
    }
}
