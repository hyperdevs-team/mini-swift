import Foundation

public typealias EmptyTask<E: Error> = Task<None, E>

public protocol TaskType {
    associatedtype Payload: Equatable
    associatedtype Failure: Error

    var isIdle: Bool { get }
    var isRunning: Bool { get }
    var isRecentlySucceeded: Bool { get }
    var isTerminal: Bool { get }
    var isSuccessful: Bool { get }
    var isFailure: Bool { get }

    var status: TaskStatus<Payload, Failure> { get }
    var payload: Payload? { get }
    var error: Failure? { get }
    var tag: String? { get }
}

public class Task<T: Equatable, E: Error>: TaskType, Equatable, CustomDebugStringConvertible {
    public typealias Payload = T
    public typealias Failure = E

    public let status: TaskStatus<Payload, Failure>
    public let started: Date
    public let expiration: TaskExpiration
    public let tag: String?
    public let progress: Decimal?

    public required init(status: TaskStatus<Payload, Failure> = .idle,
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

    public static func requestIdle(tag: String? = nil) -> Self {
        .init(status: .idle, tag: tag)
    }

    public static func requestRunning(tag: String? = nil) -> Self {
        .init(status: .running, tag: tag)
    }

    public static func requestFailure(_ error: Failure, tag: String? = nil) -> Self {
        .init(status: .failure(error: error), tag: tag)
    }

    public static func requestSuccess(_ payload: Payload, expiration: TaskExpiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: payload), expiration: expiration, tag: tag)
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
    static func requestSuccess(expiration: TaskExpiration = .immediately, tag: String? = nil) -> Self {
        .init(status: .success(payload: .none), expiration: expiration, tag: tag)
    }
}
