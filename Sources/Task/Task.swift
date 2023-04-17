import Foundation

public class Task<T: Equatable, E: Error & Equatable>: Taskable, Equatable, CustomDebugStringConvertible {
    public typealias Payload = T
    public typealias Failure = E

    public let status: TaskStatus<Payload, Failure>
    public let started: Date
    public let expiration: TaskExpiration
    public let tag: String?
    public let progress: Decimal?

    internal required init(status: TaskStatus<Payload, Failure> = .idle,
                           started: Date = Date(),
                           expiration: TaskExpiration = .immediately,
                           tag: String? = nil,
                           progress: Decimal? = nil) {
        self.status = status
        self.started = started
        self.expiration = expiration
        self.tag = tag
        self.progress = progress
    }

    public var payload: Payload? {
        switch status {
        case .success(let payload):
            return payload

        default:
            return nil
        }
    }

    public var error: Failure? {
        switch status {
        case .failure(let error):
            return error

        default:
            return nil
        }
    }

    public var isIdle: Bool {
        status == .idle
    }

    public var isRunning: Bool {
        status == .running
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

    public static func idle(started: Date, tag: String?, progress: Decimal?) -> Self {
        .init(status: .idle,
              started: started,
              tag: tag,
              progress: progress)
    }

    public static func running(started: Date, tag: String?, progress: Decimal?) -> Self {
        .init(status: .running,
              started: started,
              tag: tag,
              progress: progress)
    }

    public static func failure(_ error: Failure, started: Date, tag: String?, progress: Decimal?) -> Self {
        .init(status: .failure(error: error),
              started: started,
              tag: tag,
              progress: progress)
    }

    public static func success(_ payload: Payload, started: Date, expiration: TaskExpiration, tag: String?, progress: Decimal?) -> Self {
        .init(status: .success(payload: payload),
              started: started,
              expiration: expiration,
              tag: tag,
              progress: progress)
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
        payload: \(String(describing: payload)), progress: \(String(describing: progress)) error: \(String(describing: error))
        """
    }

    // MARK: Equatable
    public static func == <T, E> (lhs: Task<T, E>, rhs: Task<T, E>) -> Bool {
        lhs.status == rhs.status
    }
}

public extension Task where T == None {
    static func success(started: Date = Date(),
                        expiration: TaskExpiration = .immediately,
                        tag: String? = nil,
                        progress: Decimal? = nil) -> Self {
        .init(status: .success(payload: .none),
              started: started,
              expiration: expiration,
              tag: tag,
              progress: progress)
    }
}
