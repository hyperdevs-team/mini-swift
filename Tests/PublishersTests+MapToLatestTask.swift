import Combine
@testable import Mini
import XCTest

extension PublishersTests {
    func test_flatmap_identifiable_task_to_severals_successes_when_original_task_emits_severals_tasks() {
        var cancellables = Set<AnyCancellable>()
        let expectationSuccess = expectation(description: "wait for async process - Success")
        expectationSuccess.expectedFulfillmentCount = 2
        let expectationFailure = expectation(description: "wait for async process - Failure")
        expectationFailure.expectedFulfillmentCount = 3
        let expectationRunning = expectation(description: "wait for async process - Running")
        expectationRunning.expectedFulfillmentCount = 1
        let expectationIdle = expectation(description: "wait for async process - Idle")
        expectationIdle.expectedFulfillmentCount = 1

        let triggerSubject = PassthroughSubject<Task<TestPayload, TestError>, Never>()
        let internalSubject = PassthroughSubject<Task<String, TestError>, Never>()

        triggerSubject
            .mapToLatestTask { _ in
                internalSubject
                    .eraseToAnyPublisher()
            }
            .sink { task in
                switch task.status {
                case .success:
                    expectationSuccess.fulfill()

                case .idle:
                    expectationIdle.fulfill()

                case .failure:
                    expectationFailure.fulfill()

                case .running:
                    expectationRunning.fulfill()
                }
            }
            .store(in: &cancellables)

        triggerSubject.send(taskIdentifiableIdle1) // Pass- Hit IDLE!
        triggerSubject.send(taskIdentifiableRunning1) // Pass- Hit RUNNING!
        triggerSubject.send(taskIdentifiableSuccess1) // Connect subject
        internalSubject.send(taskSuccess2) // Hit SUCCESS!
        internalSubject.send(taskFailure1) // Hit FAILURE!
        triggerSubject.send(taskIdentifiableFailure1) // Pass- Hit FAILURE!
        triggerSubject.send(taskIdentifiableFailure2) // Pass- Hit FAILURE!
        internalSubject.send(taskFailure1) // Ignored
        internalSubject.send(taskFailure1) // Ignored
        internalSubject.send(taskFailure1) // Ignored
        triggerSubject.send(taskIdentifiableSuccess2)  // Connect subject
        internalSubject.send(taskSuccess1) // Hit SUCCESS!

        waitForExpectations(timeout: 2)
    }

    func test_flatmap_identifiable_task_to_success_when_original_task_is_success() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_flatmap_identifiable_task_to_success_when_original_task_is_success")
        expectation.expectedFulfillmentCount = 1

        Just(taskIdentifiableSuccess1) // Emits a task with an Id="uno"
            .mapToLatestTask { id in
                Just(self.taskSuccess(value: id)) // This task concats success with received value (id)
                    .eraseToAnyPublisher()
            }
            .sink { task in
                XCTAssertTrue(task.isSuccessful)
                XCTAssertEqual(task.payload, "success:uno")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_success() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_success")
        expectation.expectedFulfillmentCount = 2

        let subject = PassthroughSubject<Task<String, TestError>, Never>()

        Just(taskIdentifiableSuccess1) // Emits a task with an Id="uno"
            .mapToLatestTask { _ in
                subject
                    .eraseToAnyPublisher()
            }
            .sink { task in
                XCTAssertTrue(task.isSuccessful)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        subject.send(taskSuccess1)
        subject.send(taskSuccess2)

        waitForExpectations(timeout: 2)
    }

    func test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_failure() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_failure")
        expectation.expectedFulfillmentCount = 1

        let subject = PassthroughSubject<Task<String, TestError>, Never>()

        Just(taskIdentifiableFailure1)
            .mapToLatestTask { _ in
                subject
                    .eraseToAnyPublisher()
            }
            .sink { task in
                XCTAssertTrue(task.isFailure)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // These changes are omited because the trigger task is on a failure state
        subject.send(taskSuccess1)
        subject.send(taskSuccess2)

        waitForExpectations(timeout: 2)
    }

    func test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_running() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_running")
        expectation.expectedFulfillmentCount = 1

        let subject = PassthroughSubject<Task<String, TestError>, Never>()

        Just(taskIdentifiableRunning1)
            .mapToLatestTask { _ in
                subject
                    .eraseToAnyPublisher()
            }
            .sink { task in
                XCTAssertTrue(task.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // These changes are omited because the trigger task is on a failure state
        subject.send(taskSuccess1)
        subject.send(taskSuccess2)

        waitForExpectations(timeout: 2)
    }

    func test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_idle() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_flatmap_identifiable_task_to_severals_successes_when_original_task_is_idle")
        expectation.expectedFulfillmentCount = 1

        let subject = PassthroughSubject<Task<String, TestError>, Never>()

        Just(taskIdentifiableIdle1)
            .mapToLatestTask { _ in
                subject
                    .eraseToAnyPublisher()
            }
            .sink { task in
                XCTAssertTrue(task.isIdle)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // These changes are omited because the trigger task is on a failure state
        subject.send(taskSuccess1)
        subject.send(taskSuccess2)

        waitForExpectations(timeout: 2)
    }
}
