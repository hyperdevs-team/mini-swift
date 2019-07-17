//
//  Observable+Extensions.swift
//
//
//  Created by Jorge Revuelta on 17/07/2019.
//

import Foundation
import Combine

extension Publisher {

    public func dispatch<A: CompletableAction>(_ action: A.Type,
                                               expiration: Task.Expiration = .long,
                                               on dispatcher: Dispatcher,
                                               method dispatchMethod: Dispatcher.DispatchMode.UI = .async,
                                               fillOnError errorPayload: A.Payload? = nil)
        -> Cancellable where A.Payload == Self.Output {
            let subscription = self.sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        let action = A(task: .requestFailure(withError: error),
                                       payload: errorPayload)
                        dispatcher.dispatch(action, mode: dispatchMethod)
                    }
                },
                receiveValue: { (payload: A.Payload) -> Void in
                    let action = A(task: .requestSuccess(expiration: expiration),
                                   payload: payload)
                    dispatcher.dispatch(action, mode: dispatchMethod)
                }
            )
            return subscription
    }
}
