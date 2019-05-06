import Foundation

public typealias Task = TypedTask<Any>
public typealias KeyedTask<K: Hashable> = [K: Task]

public class TypedTask<T>: Equatable, CustomDebugStringConvertible {
    public enum Status {
        case idle
        case running
        case success
        case failure
    }

    public enum Expiration {
        case immediately
        case short
        case long
        case custom(TimeInterval)

        public var value: TimeInterval {
            switch self {
            case .immediately: return 0
            case .short: return 60
            case .long: return 180
            case .custom(let value): return value
            }
        }
    }

    public let status: Status
    public let started: Date
    public let expiration: Expiration
    public let data: T?
    public let progress: Decimal?
    public let error: Error?

    public required init(status: Status = .idle,
                         started: Date = Date(),
                         expiration: Expiration = .long,
                         data: T? = nil,
                         progress: Decimal? = nil,
                         error: Error? = nil) {
        self.status = status
        self.started = started
        self.expiration = expiration
        self.data = data
        self.progress = progress
        self.error = error
    }

    public var isRunning: Bool {
        return self.status == .running
    }

    public var isRecentlySucceeded: Bool {
        return status == .success && started.timeIntervalSinceNow + expiration.value >= 0
    }

    public var isTerminal: Bool {
        return status == .success || status == .failure
    }

    public var isSuccessful: Bool {
        return status == .success
    }

    public var isFailure: Bool {
        return status == .failure
    }

    public static func requestRunning() -> Task {
        return Task(status: .running)
    }

    public static func requestSuccess(expiration: Task.Expiration = .long) -> Task {
        return Task(status: .success, expiration: expiration)
    }

    public static func requestFailure(withError error: Error) -> Task {
        return Task(status: .failure, error: error)
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        return "🚀 Task: status: \(status), started: \(started), " +
        "data: \(String(describing: data)), progress: \(String(describing: progress)) error: \(String(describing: error))"
    }
}

public func ==<T> (lhs: TypedTask<T>, rhs: TypedTask<T>) -> Bool {
    return lhs.status == rhs.status &&
        lhs.started == rhs.started &&
        lhs.progress == rhs.progress
}
