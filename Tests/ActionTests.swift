@testable import Mini
import XCTest

final class ActionTests: XCTestCase {
    func test_check_computed_vars() {
        let payloadTask = Task<String, TestError>.requestIdle()
        let emptyTask = EmptyTask<TestError>.requestRunning()

        let emptyAction = TestEmptyAction(task: emptyTask)
        XCTAssertEqual(emptyAction.task, emptyTask)

        let completableAction = TestCompletableAction(task: payloadTask)
        XCTAssertEqual(completableAction.task, payloadTask)

        let keyedCompletableAction = TestKeyedCompletableAction(task: payloadTask, key: "1")
        XCTAssertTrue(keyedCompletableAction.task == payloadTask)
        XCTAssertTrue(keyedCompletableAction.key == "1")

        let keyedEmptyAction = TestKeyedEmptyAction(task: emptyTask, key: "1")
        XCTAssertTrue(keyedEmptyAction.task == emptyTask)
        XCTAssertTrue(keyedEmptyAction.key == "1")
    }
}
