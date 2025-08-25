import Combine

public extension Publisher {
    func removeExpired(margin: TimeInterval = taskDefaultMargin) -> Publishers.RemoveExpired<Self>
    where Output: Taskable {
        Publishers.RemoveExpired(upstream: self, margin: margin)
    }
}

public extension Publishers {
    /// Create a `Publisher` that connect an Upstream (Another publisher) that filter any expired task received
    /// The Output of this `Publisher` is the same of the Upstream.
    struct RemoveExpired<Upstream: Publisher>: Publisher where Upstream.Output: Taskable {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream
        private let margin: TimeInterval

        public init(upstream: Upstream, margin: TimeInterval) {
            self.upstream = upstream
            self.margin = margin
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Output == S.Input {
            upstream.subscribe(Inner(downstream: subscriber, margin: margin))
        }
    }
}

extension Publishers.RemoveExpired {
    private struct Inner<Downstream: Subscriber>: Subscriber
    where Downstream.Input == Output, Downstream.Failure == Upstream.Failure, Output: Taskable {
        let combineIdentifier = CombineIdentifier()
        private let downstream: Downstream
        private let margin: TimeInterval

        fileprivate init(downstream: Downstream, margin: TimeInterval) {
            self.downstream = downstream
            self.margin = margin
        }

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            if input.isExpired(margin: margin) {
                return .none
            }
            return downstream.receive(input)
        }

        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            downstream.receive(completion: completion)
        }
    }
}
