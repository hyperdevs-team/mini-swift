import Foundation

public let taskDefaultMargin: TimeInterval = 0.250

public class Task<T: Equatable, E: Error & Equatable>: Taskable, CustomDebugStringConvertible, CustomStringConvertible {
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

    public func isExpired(margin: TimeInterval) -> Bool {
        started.timeIntervalSinceNow + expiration.value + margin < 0
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

    // MARK: - CustomStringConvertible
    public var description: String {
        "[TASK] \(status) - started: \(started)"
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        "[TASK] \(status) - started: \(started) - expiration \(expiration)"
    }

    // MARK: Equatable
    public static func == (lhs: Task, rhs: Task) -> Bool {
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
