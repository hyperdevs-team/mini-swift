import Foundation
import Mini

struct TestStateWithOneTask: State {
    public let testTask: Task<Int, TestError>
    public let counter: Int

    public init(testTask: Task<Int, TestError> = .idle(),
                counter: Int = 0) {
        self.testTask = testTask
        self.counter = counter
    }
}
