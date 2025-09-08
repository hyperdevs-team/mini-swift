import Combine
import Foundation
import Mini
import XCTest

class TestStoreController: Cancellable {
    public func cancel() {
        // NO-OP
    }
}

typealias TestStore = Store<TestStateWithOneTask, TestStoreController>

extension TestStore {
    func reducerGroup(expectation: XCTestExpectation? = nil) -> ReducerGroup {
        ReducerGroup { [
            Reducer(of: TestAction.self, on: self.dispatcher) { action in
                self.state = TestStateWithOneTask(testTask: .success(action.counter), counter: action.counter)
                expectation?.fulfill()
            }
        ]
        }
    }
}
