import Combine
import Foundation

public extension Publisher {
    func combineMiniTasks<T: TaskType>()
    -> Publishers.CombineMiniTasksArray<Self, [T.Payload], T.Failure>
    where Output == [T] {
        Publishers.CombineMiniTasksArray(upstream: self)
    }
}

public extension Publishers {
    struct CombineMiniTasksArray<Upstream: Publisher, TaskPayload: Equatable, TaskFailure: Error>: Publisher {
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

extension Publishers.CombineMiniTasksArray {
    private struct Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Upstream.Failure {
        let combineIdentifier = CombineIdentifier()
        private let downstream: Downstream

        fileprivate init(downstream: Downstream) {
            self.downstream = downstream
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            guard let tasks = input as? [any TaskType] else {
                fatalError("Imposible!")
            }

            if tasks.map({ $0.isRunning }).contains(true) {
                return downstream.receive(.requestRunning())
            }

            if let failureTask = tasks.first(where: { $0.isFailure }), let failure = failureTask.error as? Output.Failure {
                return downstream.receive(.requestFailure(failure))
            }

            if
                !tasks.map({ $0.isSuccessful }).contains(false),
                let payload = tasks.compactMap({ $0.payload }) as? TaskPayload {
                return downstream.receive(.requestSuccess(payload))
            }

            return downstream.receive(.requestIdle())
        }

        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
