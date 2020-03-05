@testable import MiniTasks
import XCTest

class TaskTests: XCTestCase {
    let error = NSError(domain: #function, code: -1, userInfo: nil)

    func test_check_states_for_idle_task() {
        let task = AnyTask.idle()

        XCTAssertEqual(task.status, .idle)
        XCTAssertNil(task.error)

        XCTAssertFalse(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertFalse(task.isCompleted)
        XCTAssertFalse(task.isSuccessful)
    }

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

    func test_check_states_for_success_typed_task() {
        let task: TypedTask<Int> = AnyTask.success(1)

        XCTAssertEqual(task.status, .success)
        XCTAssertNil(task.error)

        XCTAssertFalse(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertTrue(task.isCompleted)
        XCTAssertTrue(task.isSuccessful)
        XCTAssertEqual(task.data, 1)
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

    func test_task_properties() {
        let task: AnyTask = .idle()
        let date = Date()
        task.date = date

        XCTAssertEqual(task.date as Date?, date)
        XCTAssertNil(task.not_a_property as Int?)
    }
}
