//
//  FilterOne.swift
//  
//
//  Created by Jorge Revuelta on 25/07/2019.
//

import Foundation
import Combine

extension Publishers {

    public struct FilterOne<Upstream>: Publisher where Upstream: Publisher {

        public typealias Where = (Upstream.Output) -> Bool

        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let _where: Where
        public let upstream: Upstream

        init(upstream: Upstream, where condition: @escaping Where) {
            self._where = condition
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, Upstream.Failure == S.Failure {
            let sink = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: { subscription in
                    subscriber.receive(subscription: subscription)
                },
                receiveValue: { event in
                    let satisfies = self._where(event)
                    if satisfies {
                        let demand = subscriber.receive(event)
                        return demand
                    }
                    return .unlimited
                },
                receiveCompletion: { completion in
                    subscriber.receive(completion: completion)
                }
            )
            self.upstream.subscribe(sink)
        }
    }
}

extension Publisher {

    public func filterOne(_ condition: @escaping (Self.Output) -> Bool) -> Publishers.FilterOne<Self> {
        Publishers.FilterOne(upstream: self, where: condition)
    }
}
