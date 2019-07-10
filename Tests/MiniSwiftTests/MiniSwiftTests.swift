import XCTest
import Combine
@testable import MiniSwift

final class MiniSwiftTests: XCTestCase {

    class OneTestAction: Action {

        func isEqual(to other: Action) -> Bool {
            return other is OneTestAction
        }
    }

    struct TestState: State {

        let testTask: Task

        init(testTask: Task = Task()) {
            self.testTask = testTask
        }

        func isEqual(to other: State) -> Bool {
            return other is TestState
        }
    }

    class TestStore: Store<TestState> {

        let dispatcher: Dispatcher

        var changes: Int = 0

        init(dispatcher: Dispatcher) {
            self.dispatcher = dispatcher
            let initialState = TestState()
            super.init(state: initialState, dispatcher: dispatcher)
        }

        override var reducerGroup: ReducerGroup {
            ReducerGroup {
                Reducer(of: OneTestAction.self, on: self.dispatcher) { _ in
                    self.changes += 1
                }
            }
        }
    }

    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        let dispatcher = Dispatcher()
        let store = TestStore(dispatcher: dispatcher)
        let action = OneTestAction()
        XCTAssertTrue(store.changes == 0)
        dispatcher.dispatch(action, mode: .sync)
        XCTAssertTrue(store.changes == 1)
    }

    static var allTests = [
        ("test_dispatcher_triggers_action_in_reducer_group_reducer",
         test_dispatcher_triggers_action_in_reducer_group_reducer)
    ]
}
