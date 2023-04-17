import Foundation
import Mini

struct TestState: State {
    public let testTask: Task<None, TestError>
    public let counter: Int

    public init(testTask: Task<None, TestError> = .idle(),
                counter: Int = 0) {
        self.testTask = testTask
        self.counter = counter
    }
}
