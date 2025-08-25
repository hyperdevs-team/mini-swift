import Combine
import Foundation

public protocol Group: Cancellable {
    var cancellables: Set<AnyCancellable> { get }
}

public class ReducerGroup: Group {
    public var cancellables = Set<AnyCancellable>()

    public init(_ builder: () -> [Cancellable]) {
        let disposable = builder()
        disposable.forEach { _ = cancellables.insert(AnyCancellable($0)) }
    }

    public func cancel() {
        cancellables.removeAll()
        cancellables = Set<AnyCancellable>()
    }
}
