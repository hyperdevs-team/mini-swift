@testable import Mini
@testable import MiniTasks
import Nimble
import XCTest

final class ActionTests: XCTestCase {
    struct TasksTestEmptyAction: MiniTasks.EmptyAction {
        let task: AnyTask
    }

    func test_action_tag() {
        let action = SetCounterAction(counter: 1)

        XCTAssertEqual(String(describing: type(of: action)), SetCounterAction.tag)
    }

    func test_empty_action_fatal_error_initializer() {
        expect {
            _ = TasksTestEmptyAction(task: .success(), payload: nil)
        }.to(throwAssertion())
    }
}
