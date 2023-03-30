import Foundation

public protocol PayloadAction {
    associatedtype TaskPayload: Equatable
    associatedtype TaskError: Error & Equatable

    var task: Task<TaskPayload, TaskError> { get }

    init(task: Task<TaskPayload, TaskError>)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction {
    associatedtype TaskPayload = None

    init(task: EmptyTask<TaskError>)
}
