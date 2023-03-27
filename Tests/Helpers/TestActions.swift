import Foundation
import Mini

class TestAction: Action {
    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

class TestCompletableAction: CompletableAction {
    typealias TaskPayload = String
    typealias TaskError = TestError

    let task: Task<TaskPayload, TaskError>

    required init(task: Task<TaskPayload, TaskError>) {
        self.task = task
    }

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestCompletableAction else { return false }
        guard task == action.task else { return false }
        return true
    }
}

class TestEmptyAction: EmptyAction {
    typealias TaskError = TestError

    let task: EmptyTask<TaskError>

    required init(task: EmptyTask<TaskError>) {
        self.task = task
    }

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestEmptyAction else { return false }
        guard task == action.task else { return false }
        return true
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

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestKeyedCompletableAction else { return false }
        guard task == action.task else { return false }
        return true
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

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestKeyedEmptyAction else { return false }
        guard task == action.task else { return false }
        return true
    }
}

class TestAttributedAction: AttributedAction {
    typealias Attribute = String

    let attribute: Attribute

    required init(attribute: Attribute) {
        self.attribute = attribute
    }

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestAttributedAction else { return false }
        guard attribute == action.attribute else { return false }
        return true
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

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestAttributedEmptyAction else { return false }
        guard attribute == action.attribute else { return false }
        guard task == action.task else { return false }
        return true
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

    func isEqual(to other: Action) -> Bool {
        guard let action = other as? TestAttributedCompletableAction else { return false }
        guard attribute == action.attribute else { return false }
        guard task == action.task else { return false }
        return true
    }
}
