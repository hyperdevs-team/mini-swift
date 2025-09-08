import Foundation
import Mini

struct TestStateWithTwoTasks: State {
    public let testTask1: Task<Int, TestError>
    public let testTask2: Task<Int, TestError>

    public init(testTask1: Task<Int, TestError> = .idle(),
                testTask2: Task<Int, TestError> = .idle()) {
        self.testTask1 = testTask1
        self.testTask2 = testTask2
    }
}
