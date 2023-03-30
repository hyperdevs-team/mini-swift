import Combine
import Foundation

public protocol TaskTuple2PayloadType: Equatable {
    associatedtype T1Payload: Equatable
    associatedtype T2Payload: Equatable
}

public struct TaskTuple2Payload<T1P: Equatable, T2P: Equatable>: TaskTuple2PayloadType {
    public typealias T1Payload = T1P
    public typealias T2Payload = T2P

    public let value1: T1Payload
    public let value2: T2Payload

    public init(_ value1: T1Payload, _ value2: T2Payload) {
        self.value1 = value1
        self.value2 = value2
    }
}

public extension Publisher {
    func combineMiniTasks<T1: TaskType, T2: TaskType>()
    -> Publishers.CombineMiniTasksTuple2<Self, TaskTuple2Payload<T1.Payload, T2.Payload>, T1.Failure>
    where Output == (T1, T2), T1.Failure == T2.Failure {
        Publishers.CombineMiniTasksTuple2(upstream: self)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that emits `Task` (Array or Tuples)
    /// The Output of this Publisher always is a combined `Task`
    struct CombineMiniTasksTuple2<Upstream: Publisher, TaskPayload: TaskTuple2PayloadType, TaskFailure: Error & Equatable>: Publisher {
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

extension Publishers.CombineMiniTasksTuple2 {
    private struct Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Upstream.Failure, TaskPayload: TaskTuple2PayloadType {
        let combineIdentifier = CombineIdentifier()
        private let downstream: Downstream

        fileprivate init(downstream: Downstream) {
            self.downstream = downstream
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            guard let tuple = input as? (any TaskType, any TaskType) else {
                fatalError("Imposible!")
            }

            if tuple.0.isRunning || tuple.1.isRunning {
                return downstream.receive(.requestRunning())
            }

            if
                tuple.0.isFailure || tuple.1.isFailure,
                let failure = tuple.0.error as? Output.Failure ??
                    tuple.1.error as? Output.Failure
            {
                return downstream.receive(.requestFailure(failure))
            }

            if
                tuple.0.isSuccessful && tuple.1.isSuccessful,
                let payload1 = tuple.0.payload as? TaskPayload.T1Payload,
                let payload2 = tuple.1.payload as? TaskPayload.T2Payload,
                let payload = TaskTuple2Payload(payload1, payload2) as? TaskPayload
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
