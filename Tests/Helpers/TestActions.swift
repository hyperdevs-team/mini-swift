import Foundation
import Mini

class TestAction: Action {
    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }
}

class TestCompletableAction: CompletableAction {
    typealias TaskPayload = String
    typealias TaskError = TestError

    let task: Task<TaskPayload, TaskError>

    required init(task: Task<TaskPayload, TaskError>) {
        self.task = task
    }
}

class TestEmptyAction: EmptyAction {
    typealias TaskError = TestError

    let task: EmptyTask<TaskError>

    required init(task: EmptyTask<TaskError>) {
        self.task = task
    }
}

class TestKeyedCompletableAction: KeyedCompletableAction {
    typealias TaskPayload = String
    typealias TaskError = TestError
    typealias Key = String

    let task: Task<TaskPayload, TaskError>
    let key: Key

    required init(task: Task<TaskPayload, TaskError>, key: String) {
        self.task = task
        self.key = key
    }
}

class TestKeyedEmptyAction: KeyedEmptyAction {
    typealias TaskError = TestError
    typealias Key = String

    let task: EmptyTask<TaskError>
    let key: Key

    required init(task: EmptyTask<TaskError>, key: String) {
        self.task = task
        self.key = key
    }
}

class TestAttributedAction: AttributedAction {
    typealias Attribute = String

    let attribute: Attribute

    required init(attribute: Attribute) {
        self.attribute = attribute
    }
}

class TestAttributedEmptyAction: AttributedEmptyAction {
    typealias TaskError = TestError
    typealias Attribute = String

    let attribute: Attribute
    let task: EmptyTask<TaskError>

    required init(task: EmptyTask<TaskError>, attribute: Attribute) {
        self.attribute = attribute
        self.task = task
    }
}

class TestAttributedCompletableAction: AttributedCompletableAction {
    typealias TaskPayload = String
    typealias TaskError = TestError
    typealias Attribute = String

    let attribute: Attribute
    let task: Task<TaskPayload, TaskError>

    required init(task: Task<TaskPayload, TaskError>, attribute: Attribute) {
        self.attribute = attribute
        self.task = task
    }
}
