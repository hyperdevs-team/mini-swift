import Foundation

public typealias Task = TypedTask<Any>

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
            case .immediately:
                return 0

            case .short:
                return 60

            case .long:
                return 180

            case .custom(let value):
                return value
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
                         expiration: Expiration = .immediately,
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

    public var isIdle: Bool {
        status == .idle
    }

    public var isRunning: Bool {
        status == .running
    }

    public var isRecentlySucceeded: Bool {
        status == .success && started.timeIntervalSinceNow + expiration.value >= 0
    }

    public var isTerminal: Bool {
        status == .success || status == .failure
    }

    public var isSuccessful: Bool {
        status == .success
    }

    public var isFailure: Bool {
        status == .failure
    }

    public static func requestRunning() -> Task {
        Task(status: .running)
    }

    public static func requestSuccess(_ expiration: Task.Expiration = .immediately) -> Task {
        Task(status: .success, expiration: expiration)
    }

    public static func requestFailure(_ error: Error) -> Task {
        Task(status: .failure, error: error)
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        """
        🚀 Task: status: \(status), started: \(started),
        data: \(String(describing: data)), progress: \(String(describing: progress)) error: \(String(describing: error))
        """
    }
}

public func ==<T> (lhs: TypedTask<T>, rhs: TypedTask<T>) -> Bool {
    lhs.status == rhs.status &&
        lhs.started == rhs.started &&
        lhs.progress == rhs.progress
}
