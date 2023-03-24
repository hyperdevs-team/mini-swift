import Combine
import Foundation

public protocol TaskTuple4PayloadType: Equatable {
    associatedtype T1Payload: Equatable
    associatedtype T2Payload: Equatable
    associatedtype T3Payload: Equatable
    associatedtype T4Payload: Equatable
}

public struct TaskTuple4Payload<T1P: Equatable, T2P: Equatable, T3P: Equatable, T4P: Equatable>: TaskTuple4PayloadType {
    public typealias T1Payload = T1P
    public typealias T2Payload = T2P
    public typealias T3Payload = T3P
    public typealias T4Payload = T4P

    public let value1: T1Payload
    public let value2: T2Payload
    public let value3: T3Payload
    public let value4: T4Payload

    public init(_ value1: T1Payload, _ value2: T2Payload, _ value3: T3Payload, _ value4: T4Payload) {
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
    }
}

public extension Publisher {
    func combineMiniTasks<T1: TaskType, T2: TaskType, T3: TaskType, T4: TaskType>()
    -> Publishers.CombineMiniTasksTuple4<Self, TaskTuple4Payload<T1.Payload, T2.Payload, T3.Payload, T4.Payload>, T1.Failure>
    where Output == (T1, T2, T3, T4), T1.Failure == T2.Failure, T1.Failure == T3.Failure, T1.Failure == T4.Failure {
        Publishers.CombineMiniTasksTuple4(upstream: self)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that emits `Task` (Array or Tuples)
    /// The Output of this Publisher always is a combined `Task`
    struct CombineMiniTasksTuple4<Upstream: Publisher, TaskPayload: TaskTuple4PayloadType, TaskFailure: Error>: Publisher {
        public typealias Output = Task<TaskPayload, TaskFailure>
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Output == S.Input {
            upstream.subscribe(Inner(downstream: subscriber))
        }
    }
}

extension Publishers.CombineMiniTasksTuple4 {
    private struct Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Upstream.Failure, TaskPayload: TaskTuple4PayloadType {
        let combineIdentifier = CombineIdentifier()
        private let downstream: Downstream

        fileprivate init(downstream: Downstream) {
            self.downstream = downstream
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            guard let tuple = input as? (any TaskType, any TaskType, any TaskType, any TaskType) else {
                fatalError("Imposible!")
            }

            if tuple.0.isRunning || tuple.1.isRunning || tuple.2.isRunning || tuple.3.isRunning {
                return downstream.receive(.requestRunning())
            }

            if
                tuple.0.isFailure || tuple.1.isFailure || tuple.2.isFailure || tuple.3.isFailure,
                let failure = tuple.0.error as? Output.Failure ??
                    tuple.1.error as? Output.Failure ??
                    tuple.2.error as? Output.Failure ??
                    tuple.3.error as? Output.Failure
            {
                return downstream.receive(.requestFailure(failure))
            }

            if
                tuple.0.isSuccessful && tuple.1.isSuccessful, tuple.2.isSuccessful && tuple.3.isSuccessful,
                let payload1 = tuple.0.payload as? TaskPayload.T1Payload,
                let payload2 = tuple.1.payload as? TaskPayload.T2Payload,
                let payload3 = tuple.2.payload as? TaskPayload.T3Payload,
                let payload4 = tuple.3.payload as? TaskPayload.T4Payload,
                let payload = TaskTuple4Payload(payload1, payload2, payload3, payload4) as? TaskPayload
            {
                return downstream.receive(.requestSuccess(payload))
            }

            return downstream.receive(.requestIdle())
        }

        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
