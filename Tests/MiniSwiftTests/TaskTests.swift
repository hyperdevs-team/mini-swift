@testable import Task
import XCTest

class TaskTests: XCTestCase {
    let error = NSError(domain: #function, code: -1, userInfo: nil)

    func test_check_states_for_running_task() {
        let task = AnyTask.running()

        XCTAssertEqual(task.status, .running)
        XCTAssertNil(task.error)

        XCTAssertTrue(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertFalse(task.isCompleted)
        XCTAssertFalse(task.isSuccessful)
    }

    func test_check_states_for_success_task() {
        let task = AnyTask.success()

        XCTAssertEqual(task.status, .success)
        XCTAssertNil(task.error)

        XCTAssertFalse(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertTrue(task.isCompleted)
        XCTAssertTrue(task.isSuccessful)
    }

    func test_check_states_for_failure_task() {
        let task = AnyTask.failure(error)

        XCTAssertEqual(task.status, .error)
        XCTAssertEqual(task.error as NSError?, error)

        XCTAssertFalse(task.isRunning)
        XCTAssertTrue(task.isFailure)
        XCTAssertTrue(task.isCompleted)
        XCTAssertFalse(task.isSuccessful)
    }
}
