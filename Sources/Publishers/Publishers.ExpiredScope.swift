import Combine
import Foundation

public extension Publisher {
    /// From a publisher, we can focus on a task and filter all expired and duplicated task. This publisher doesn't send a value if at the moment of subscription there is an expired task.
    @available(*, deprecated, renamed: "scope")
    func expiredScope<T: Taskable>(_ transform: @escaping (Self.Output) -> T, margin: TimeInterval = taskDefaultMargin) -> AnyPublisher<T, Failure> {
        map(transform)
            .removeExpired(margin: margin)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
