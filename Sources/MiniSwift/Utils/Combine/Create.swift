//
//  Create.swift
//  
//
//  Created by Jorge Revuelta on 29/07/2019.
//

import Foundation
import Combine

extension Publishers {

    public struct Create<Output, Failure: Error>: Publisher {
        public typealias Output = Output
        public typealias Failure = Failure

        private let create: (AnySubscriber<Output, Failure>) -> Subscription
        private var cancellable: Subscription?

        public init<S: Subscription>(create: @escaping (AnySubscriber<Output, Failure>) -> S) {
            self.create = create
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: create(AnySubscriber(subscriber)))
        }
    }
}

extension AnyCancellable: Subscription {
    public func request(_ demand: Subscribers.Demand) { }
}
