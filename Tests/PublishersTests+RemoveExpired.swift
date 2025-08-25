import Combine
@testable import Mini
import XCTest

extension PublishersTests {
    func test_remove_expired() {
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "test_remove_expired")
        expectation.expectedFulfillmentCount = 1

        let subject = PassthroughSubject<Task<String, TestError>, Never>()

        let margin: TimeInterval = 0.500

        subject
            .removeExpired(margin: margin) // Filter the 2 expired task
            .removeDuplicates() // Pass only the first success task because the expired they never get here!
            .sink { task in
                XCTAssertFalse(task.isExpired(margin: margin))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Send 2 unexpired and 2 expired:
        subject.send(taskSuccess1)
        subject.send(taskSuccessExpired)
        subject.send(taskFailureExpired)
        subject.send(taskSuccess1)

        waitForExpectations(timeout: 2)
    }
}
