import XCTest
import Combine
@testable import MiniSwift

typealias TestStore = Store<TestState, TestStoreController>

final class DispatchTests: XCTestCase {
    
    func test_dispatch_executes_certain_given_action() {
        
        let cancellableBag = CancellableBag()
        
        let dispatcher = Dispatcher()
        
        let store = TestStore(TestState(),
                              dispatcher: dispatcher,
                              storeController: TestStoreController())
        
        store.reducerGroup.cancelled(by: cancellableBag)
        
        let expectation = XCTestExpectation(description: "Dispatch")
        
        var state: TestState?
        
        Publishers.Dispatch<TestStore>(
            using: dispatcher,
            factory: OneTestAction(counter: 1),
            taskMap: { $0.testTask },
            on: store
        )
        .sink(
            receiveCompletion: { _ in
                XCTFail()
            },
            receiveValue: { _state in
                state = _state
                expectation.fulfill()
            }
        )
        .cancelled(by: cancellableBag)
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssert(state?.counter == 1)
        XCTAssert(state?.testTask.isSuccessful == true)
    }
}
