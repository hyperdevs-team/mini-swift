import Combine

public extension Publisher {
    func eraseToEmptyTask() -> Publishers.EraseToEmptyTask<Self, Output.Failure>
    where Output: TaskType {
        Publishers.EraseToEmptyTask(upstream: self)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that type erases `Task`s to `EmptyTask`
    /// The Output of this `Publisher` always is a combined `EmptyTask`
    struct EraseToEmptyTask<Upstream: Publisher, TaskFailure: Error>: Publisher where Upstream.Output: TaskType, Upstream.Output.Failure == TaskFailure {
        public typealias Output = EmptyTask<TaskFailure>
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

extension Publishers.EraseToEmptyTask {
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
            switch input.status {
            case .success:
                return downstream.receive(.requestSuccess())

            case .idle:
                return downstream.receive(.requestIdle())

            case .running:
                return downstream.receive(.requestRunning())

            case .failure(let error):
                return downstream.receive(.requestFailure(error))
            }
        }

        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
