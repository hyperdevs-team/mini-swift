import Combine
import Foundation
import RxSwift

extension Store: Publisher {
    public typealias Output = State
    public typealias Failure = Never

    public class StoreSubscription<Target: Subscriber>: Subscription where Target.Input == State, Target.Failure == Never {
        private var disposable: Disposable?
        private let buffer: DemandBuffer<Target>

        public init(store: Store, target: Target) {
            buffer = DemandBuffer(subscriber: target)
            disposable = store.subscribe(bufferRxEvents)
        }

        public func request(_ demand: Subscribers.Demand) {
            _ = buffer.demand(demand)
        }

        public func cancel() {
            disposable?.dispose()
            disposable = nil
        }

        private func bufferRxEvents(_ event: RxSwift.Event<State>) {
            switch event {
            case .next(let element):
                _ = buffer.buffer(value: element)

            case .error(_):
                fatalError("This subscription never emit an error")

            case .completed:
                buffer.complete(completion: .finished)
            }
        }
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        let subscription = StoreSubscription(store: self, target: subscriber)
        subscriber.receive(subscription: subscription)
    }
}
