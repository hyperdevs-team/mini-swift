@testable import Mini
import XCTest

class TaskTests: XCTestCase {
    let error = NSError(domain: "wawa", code: 69, userInfo: nil)

    func test_check_states_for_running_task() {
        let task = Task.requestRunning()

        XCTAssertEqual(task.status, .running)
        XCTAssertNil(task.error)

        XCTAssertTrue(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertFalse(task.isTerminal)
        XCTAssertFalse(task.isSuccessful)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_check_states_for_success_task() {
        let task = TypedTask<Int>(status: .success(payload: 5))

        XCTAssertTrue(task.status == .success(payload: 5))
        XCTAssertNil(task.error)

        XCTAssertFalse(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertTrue(task.isTerminal)
        XCTAssertTrue(task.isSuccessful)
    }

    func test_check_states_for_failure_task() {
        let task = Task.requestFailure(error)

        XCTAssertNotEqual(task.status, .failure(error: error))
        XCTAssertEqual(task.error as NSError?, error)

        XCTAssertFalse(task.isRunning)
        XCTAssertTrue(task.isFailure)
        XCTAssertTrue(task.isTerminal)
        XCTAssertFalse(task.isSuccessful)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_data_and_progress() {
        let data = "comiendo perritos calientes"
        let progress: Decimal = 0.5
        let task = TypedTask(data: data, progress: progress)

        XCTAssertEqual(task.data, data)
        XCTAssertEqual(task.progress, progress)
    }

    func test_success_task_with_payload() {
        let task = TypedTask(status: .success(payload: "hola"))

        XCTAssertEqual(task.data, "hola")
    }

    func test_expiration_of_task_created_with_past_date() {
        let task = Task(status: .success(payload: "55"), started: Date.distantPast)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_success_task_with_expiration_setted_to_immediately() {
        let task = Task.requestSuccess(.immediately)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_success_task_with_expiration_setted() {
        let task = Task.requestSuccess(.custom(2))
        XCTAssertTrue(task.isRecentlySucceeded)

        Thread.sleep(forTimeInterval: 3)
        XCTAssertFalse(task.isRecentlySucceeded)
    }
}
