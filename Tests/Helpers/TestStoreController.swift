import Combine
import Foundation
import Mini
import XCTest

class TestStoreController: Cancellable {
    public func cancel() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {
    func reducerGroup(expectation: XCTestExpectation? = nil) -> ReducerGroup {
        ReducerGroup { [
            Reducer(of: TestAction.self, on: self.dispatcher) { action in
                self.state = TestState(testTask: .success(), counter: action.counter)
                expectation?.fulfill()
            }
        ]
        }
    }
}
