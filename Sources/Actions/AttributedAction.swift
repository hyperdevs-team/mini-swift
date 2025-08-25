import Foundation

public protocol AttributedAction: Action {
    associatedtype Attribute: Equatable
    var attribute: Attribute { get }

    init(attribute: Attribute)
}

public protocol AttributedCompletableAction: Action & PayloadAction & AttributedAction {
    init(task: Task<TaskPayload, TaskError>, attribute: Attribute)
}

extension AttributedCompletableAction {
    public init(task: Task<TaskPayload, TaskError>) {
        fatalError("You must use init(task:attribute:)")
    }

    public init(attribute: Attribute) {
        fatalError("You must use init(task:attribute:)")
    }
}

public protocol AttributedEmptyAction: Action & PayloadAction & AttributedAction {
    associatedtype TaskPayload = None

    init(task: EmptyTask<TaskError>, attribute: Attribute)
}

extension AttributedEmptyAction {
    public init(task: EmptyTask<TaskError>) {
        fatalError("You must use init(task:attribute:)")
    }

    public init(attribute: Attribute) {
        fatalError("You must use init(task:attribute:)")
    }
}
