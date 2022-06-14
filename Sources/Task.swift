import Foundation

public typealias Task = TypedTask<Any>

public class TypedTask<T>: Equatable, CustomDebugStringConvertible {
    public let status: Status
    public let started: Date
    public let expiration: Expiration
    public let data: T?
    public let tag: String?
    public let progress: Decimal?
    public let error: Error?

    public required init(status: Status = .idle,
                         started: Date = Date(),
                         expiration: Expiration = .immediately,
                         data: T? = nil,
                         tag: String? = nil,
                         progress: Decimal? = nil,
                         error: Error? = nil) {
        self.status = status
        self.started = started
        self.expiration = expiration
        self.tag = tag
        self.progress = progress
        self.error = error

        if case .success(let payload) = status {
            self.data = payload
        } else {
            self.data = data
        }
    }

    public var isIdle: Bool {
        switch status {
        case .idle:
            return true

        default:
            return false
        }
    }

    public var isRunning: Bool {
        switch status {
        case .running:
            return true

        default:
            return false
        }
    }

    public var isRecentlySucceeded: Bool {
        switch status {
        case .success where started.timeIntervalSinceNow + expiration.value >= 0:
            return true

        default:
            return false
        }
    }

    public var isTerminal: Bool {
        switch status {
        case .success, .failure:
            return true

        default:
            return false
        }
    }

    public var isSuccessful: Bool {
        switch status {
        case .success:
            return true

        default:
            return false
        }
    }

    public var isFailure: Bool {
        switch status {
        case .failure:
            return true

        default:
            return false
        }
    }

    static func requestIdle(tag: String? = nil) -> Self {
        .init(status: .idle, tag: tag)
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        let tagPrint: String
        if let tag = tag {
            tagPrint = tag
        } else {
            tagPrint = "nil"
        }

        return """
        🚀 Task: status: \(status), started: \(started), tag: \(tagPrint)
        data: \(String(describing: data)), progress: \(String(describing: progress)) error: \(String(describing: error))
        """
    }
}

public extension TypedTask {
    enum Status: Equatable {
        case idle
        case running
        case success(payload: T)
        case failure(error: Error)
    }
}

public extension TypedTask.Status where T: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.running, .running):
            return true

        case (.success(let lhsPayload), .success(let rhsPayload)):
            return lhsPayload == rhsPayload

        default:
            return false
        }
    }
}

public extension TypedTask.Status {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.running, .running):
            return true

        default:
            return false
        }
    }
}

public extension TypedTask {
    enum Expiration {
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
}

public extension TypedTask where T == Any {
    static func requestRunning(tag: String? = nil) -> Self {
        .init(status: .running, tag: tag)
    }

    static func requestFailure(_ error: Error, tag: String? = nil) -> Self {
        .init(status: .failure(error: error), tag: tag, error: error)
    }

    static func requestSuccess(_ expiration: Expiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: None.none), expiration: expiration, tag: tag)
    }
}

public extension TypedTask where T == None {
    static func requestRunning(tag: String? = nil) -> Self {
        .init(status: .running, tag: tag)
    }

    static func requestFailure(_ error: Error, tag: String? = nil) -> Self {
        .init(status: .failure(error: error), tag: tag, error: error)
    }

    static func requestSuccess(_ expiration: Expiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: .none), expiration: expiration, tag: tag)
    }
}

public func ==<T> (lhs: TypedTask<T>, rhs: TypedTask<T>) -> Bool {
    lhs.status == rhs.status &&
        lhs.started == rhs.started &&
        lhs.progress == rhs.progress
}
