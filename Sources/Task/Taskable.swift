import Foundation

public protocol Taskable {
    associatedtype Payload: Equatable
    associatedtype Failure: Error & Equatable

    var isIdle: Bool { get }
    var isRunning: Bool { get }
    func isExpired(margin: TimeInterval) -> Bool
    var isRecentlySucceeded: Bool { get }
    var isTerminal: Bool { get }
    var isSuccessful: Bool { get }
    var isFailure: Bool { get }

    var status: TaskStatus<Payload, Failure> { get }
    var payload: Payload? { get }
    var error: Failure? { get }
    var tag: String? { get }

    static func idle(started: Date, tag: String?, progress: Decimal?) -> Self
    static func running(started: Date, tag: String?, progress: Decimal?) -> Self
    static func failure(_ error: Failure, started: Date, tag: String?, progress: Decimal?) -> Self
    static func success(_ payload: Payload, started: Date, expiration: TaskExpiration, tag: String?, progress: Decimal?) -> Self
}

public extension Taskable {
    var isExpired: Bool {
        self.isExpired(margin: taskDefaultMargin)
    }
}

public extension Taskable {
    static func idle(started: Date = Date(),
                     tag: String? = nil,
                     progress: Decimal? = nil) -> Self {
        idle(started: started, tag: tag, progress: progress)
    }

    static func running(started: Date = Date(),
                        tag: String? = nil,
                        progress: Decimal? = nil) -> Self {
        running(started: started, tag: tag, progress: progress)
    }

    static func failure(_ error: Failure,
                        started: Date = Date(),
                        tag: String? = nil,
                        progress: Decimal? = nil) -> Self {
        failure(error, started: started, tag: tag, progress: progress)
    }

    static func success(_ payload: Payload,
                        started: Date = Date(),
                        expiration: TaskExpiration = .immediately,
                        tag: String? = nil,
                        progress: Decimal? = nil) -> Self {
        success(payload, started: started, expiration: expiration, tag: tag, progress: progress)
    }
}
