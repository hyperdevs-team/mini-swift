import Combine
@testable import Mini
import XCTest

class StoreTests: XCTestCase {
    func test_scope_with_initial_state() {
        var cancellables = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "Scope usage check")
        expectation.expectedFulfillmentCount = 2
        let dispatcher = Dispatcher()
        let initialState = TestStateWithOneTask()
        let store = Store<TestStateWithOneTask, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())

        // DISCARDED, SCOPE IS NOT ACTIVE YET
        store.state = TestStateWithOneTask(testTask: .success(5), counter: 1)

        var counterValue = 0
        // SCOPING....
        store
            .scope { $0.testTask }
            .sink { _ in
                expectation.fulfill()
                counterValue += 1
            }
            .store(in: &cancellables)

        // THIS PASSES
        store.state = TestStateWithOneTask(testTask: .success(1), counter: 1)

        // THIS NOT PASS, had the same success value as the previous one
        store.state = TestStateWithOneTask(testTask: .success(1), counter: 2)

        // THIS PASSES
        store.state = TestStateWithOneTask(testTask: .success(3), counter: 1)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(counterValue == 2)
    }

    func test_scope_with_initial_change_after_subscriptions() {
        var cancellables = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "Scope usage check")
        expectation.expectedFulfillmentCount = 2
        let dispatcher = Dispatcher()
        let initialState = TestStateWithTwoTasks()
        let store = Store<TestStateWithTwoTasks, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())

        var counterValue = 0
        // SCOPING....
        store
            .scope { $0.testTask1 }
            .sink { _ in
                expectation.fulfill()
                counterValue += 1
            }
            .store(in: &cancellables)

        Thread.sleep(forTimeInterval: 1)

        // THIS NOT PASS: change task2
        store.state = TestStateWithTwoTasks(testTask1: store.state.testTask1,
                                            testTask2: .success(10))

        // THIS PASSES: change task1
        store.state = TestStateWithTwoTasks(testTask1: .success(6),
                                            testTask2: store.state.testTask2)

        // THIS NOT PASS: change task2
        store.state = TestStateWithTwoTasks(testTask1: store.state.testTask1,
                                            testTask2: .success(2))

        // THIS PASSES: change task1
        store.state = TestStateWithTwoTasks(testTask1: .success(7),
                                            testTask2: store.state.testTask2)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(counterValue == 2)
    }
}
