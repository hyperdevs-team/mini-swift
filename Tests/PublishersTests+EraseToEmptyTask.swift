import Combine
@testable import Mini
import XCTest

extension PublishersTests {
    // EraseToEmptyTask

    func test_erase_to_empty_task_when_task_is_idle() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_erase_to_empty_task_when_task_is_idle")
        expectation.expectedFulfillmentCount = 1

        Just(taskIdle1)
            .eraseToEmptyTask()
            .sink { task in
                XCTAssertTrue(task.isIdle)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_erase_to_empty_task_when_task_is_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_erase_to_empty_task_when_task_is_running")
        expectation.expectedFulfillmentCount = 1

        Just(taskRunning1)
            .eraseToEmptyTask()
            .sink { task in
                XCTAssertTrue(task.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_erase_to_empty_task_when_task_is_success() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_erase_to_empty_task_when_task_is_success")
        expectation.expectedFulfillmentCount = 1

        Just(taskSuccess1)
            .eraseToEmptyTask()
            .sink { task in
                XCTAssertTrue(task.isSuccessful)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_erase_to_empty_task_when_task_is_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_erase_to_empty_task_when_task_is_failure")
        expectation.expectedFulfillmentCount = 1

        Just(taskFailure1)
            .eraseToEmptyTask()
            .sink { task in
                XCTAssertTrue(task.isFailure)
                XCTAssertEqual(task.error?.localizedDescription, self.taskFailure1.error?.localizedDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }
}
