import Combine
@testable import Mini
import XCTest

class StoreTests: XCTestCase {
    func test_scope() {
        var cancellables = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "Scope usage check")
        expectation.expectedFulfillmentCount = 2
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())

        // DISCARDED, SCOPE IS NOT ACTIVE YET
        store.state = TestState(testTask: .success(5), counter: 1)

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
        store.state = TestState(testTask: .success(1), counter: 1)

        // THIS DOES NOT, had the same success value as the previous one
        store.state = TestState(testTask: .success(1), counter: 2)

        // THIS PASSES
        store.state = TestState(testTask: .success(3), counter: 1)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(counterValue == 2)
    }
}
