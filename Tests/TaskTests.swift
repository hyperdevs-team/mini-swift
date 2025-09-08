@testable import Mini
import XCTest

class TaskTests: XCTestCase {
    let error = NSError(domain: "wawa", code: 69, userInfo: nil)

    func test_description() {
        let task1: Task<Int, NSError> = .running()

        XCTAssertEqual(task1.debugDescription, "\(String(reflecting: task1))")
        XCTAssertEqual(task1.description, "\(String(describing: task1))")
        XCTAssertEqual(task1.description, "\(task1)")

        let task2: Task<Int, NSError> = .running(tag: "a")

        XCTAssertEqual(task2.debugDescription, "\(String(reflecting: task2))")
        XCTAssertEqual(task2.description, "\(String(describing: task2))")
        XCTAssertEqual(task2.description, "\(task2)")
    }

    func test_check_states_for_running_task() {
        let task: Task<Int, NSError> = .running()

        XCTAssertEqual(task.status, .running)
        XCTAssertNil(task.error)

        XCTAssertTrue(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertFalse(task.isTerminal)
        XCTAssertFalse(task.isSuccessful)
        XCTAssertFalse(task.isRecentlySucceeded)
        XCTAssertFalse(task.isExpired)
    }

    func test_check_states_for_success_task() {
        let task: Task<Int, NSError> = .success(5)

        XCTAssertEqual(task.status, .success(payload: 5))
        XCTAssertEqual(task.payload, 5)
        XCTAssertNil(task.error)

        XCTAssertFalse(task.isRunning)
        XCTAssertFalse(task.isFailure)
        XCTAssertTrue(task.isTerminal)
        XCTAssertTrue(task.isSuccessful)
        XCTAssertFalse(task.isExpired)
    }

    func test_check_states_for_failure_task() {
        let task: Task<String, NSError> = .failure(error)

        XCTAssertEqual(task.status, .failure(error: error))
        XCTAssertNil(task.payload)
        XCTAssertEqual(task.error, error)

        XCTAssertFalse(task.isRunning)
        XCTAssertTrue(task.isFailure)
        XCTAssertTrue(task.isTerminal)
        XCTAssertFalse(task.isSuccessful)
        XCTAssertFalse(task.isRecentlySucceeded)
        XCTAssertFalse(task.isExpired)
    }

    func test_check_expiration_for_custom() {
        let expectation = expectation(description: "wait for async process")
        expectation.expectedFulfillmentCount = 2

        let task: Task<String, NSError> = .success("hola", expiration: .custom(3))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(task.isExpired)
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            XCTAssertTrue(task.isExpired)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func test_check_expiration_for_immediately() {
        let expectation = expectation(description: "wait for async process")
        expectation.expectedFulfillmentCount = 2

        let task: Task<String, NSError> = .success("hola", expiration: .immediately)

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            XCTAssertFalse(task.isExpired)
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(task.isExpired)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    func test_data_and_progress() {
        let payload = "comiendo perritos calientes"
        let progress: Decimal = 0.5
        let task: Task<String, TestError> = .success(payload, progress: progress)

        XCTAssertEqual(task.payload, payload)
        XCTAssertEqual(task.progress, progress)
    }

    func test_success_task_with_payload() {
        let task: Task<String, TestError> = .success("hola")

        XCTAssertEqual(task.payload, "hola")
    }

    func test_expiration_of_task_created_with_past_date() {
        let task: Task<String, NSError> = .success("55", started: Date.distantPast)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_success_task_with_expiration_setted_to_immediately() {
        let task: Task<Int, NSError> = .success(6, expiration: .immediately)
        XCTAssertFalse(task.isRecentlySucceeded)
    }

    func test_success_task_with_expiration_setted() {
        let task: Task<Int, NSError> = .success(66, expiration: .custom(2))
        XCTAssertTrue(task.isRecentlySucceeded)

        Thread.sleep(forTimeInterval: 3)
        XCTAssertFalse(task.isRecentlySucceeded)
    }
}
