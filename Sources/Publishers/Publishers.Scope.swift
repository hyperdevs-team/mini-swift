import Combine
import Foundation

public extension Publisher {
    /// From a publisher, we can focus on a task and filter all expired and duplicated task. This publisher don't send value if at suscription moment there is a expired task.
    func scope<T: Taskable & Equatable>(_ transform: @escaping (Self.Output) -> T) -> AnyPublisher<T, Failure> {
        map(transform)
            .removeExpired()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
