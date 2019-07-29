//
//  Observable+Extensions.swift
//
//
//  Created by Jorge Revuelta on 17/07/2019.
//

import Foundation
import Combine

extension Publisher {

    /**
     Publisher extensions that dispatches a certain `Action` when the subscription receives a value through the emitter. Uses `CompletableAction`s to fill with the emitter values new actions and with the corresponding error if any occurred in the `Publisher`.
     
     - Parameter action: The type of the `CompletableAction` that will be fulfilled with the emitter.
     - Parameter expiration: The `Task`'s expiration time.
     - Parameter dispatcher: The `Dispatcher` to send the `Action` to.
     - Parameter method: The method of dispatching the `Action`.
     - Parameter fillOnError: The default `Payload` of the `Action` if an error occurred.
     
     - Returns: A `Cancellable` instance.
     */
    public func dispatch<A: CompletableAction>(_ action: A.Type,
                                               expiration: Task.Expiration = .long,
                                               on dispatcher: Dispatcher,
                                               method dispatchMethod: Dispatcher.DispatchMode.UI = .async,
                                               fillOnError errorPayload: A.Payload? = nil)
        -> Cancellable where A.Payload == Self.Output {
            let subscription = self.sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        let action = A(task: .requestFailure(error),
                                       payload: errorPayload)
                        dispatcher.dispatch(action, mode: dispatchMethod)
                    }
                },
                receiveValue: { (payload: A.Payload) -> Void in
                    let action = A(task: .requestSuccess(expiration),
                                   payload: payload)
                    dispatcher.dispatch(action, mode: dispatchMethod)
                }
            )
            return subscription
    }
    
    /**
         Publisher extensions that dispatches a certain `Action` when the subscription receives a value through the emitter. Uses `KeyedCompletableAction`s to fill with the emitter values new actions and with the corresponding error if any occurred in the `Publisher`.
         
         - Parameter action: The type of the `KeyedCompletableAction` that will be fulfilled with the emitter.
         - Parameter expiration: The `Task`'s expiration time.
         - Parameter key: The key under the `Task` is sorted.
         - Parameter dispatcher: The `Dispatcher` to send the `Action` to.
         - Parameter method: The method of dispatching the `Action`.
         - Parameter fillOnError: The default `Payload` of the `Action` if an error occurred.
         
         - Returns: A `Cancellable` instance.
    */
    public func dispatch<A: KeyedCompletableAction>(_ action: A.Type,
                                                    expiration: Task.Expiration = .long,
                                                    key: A.Key,
                                                    on dispatcher: Dispatcher,
                                                    method dispatchMethod: Dispatcher.DispatchMode.UI = .async,
                                                    fillOnError errorPayload: A.Payload? = nil)
        -> Cancellable where A.Payload == Self.Output {
            let subscription = self.sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        let action = A(task: .requestFailure(error), payload: errorPayload, key: key)
                        dispatcher.dispatch(action, mode: dispatchMethod)
                    }
                },
                receiveValue: { (payload: A.Payload) -> Void in
                    let action = A(task: .requestSuccess(expiration), payload: payload, key: key)
                    dispatcher.dispatch(action, mode: dispatchMethod)
                }
            )
            return subscription
    }
}

extension Publisher where Output == Swift.Never {
    
    /**
         Publisher extensions that dispatches a certain `Action` when the subscription receives a value through the emitter. Uses `EmptyAction`s to fill with the emitter values new actions and with the corresponding error if any occurred in the `Publisher`.
         
         - Parameter action: The type of the `EmptyAction` that will be fulfilled with the emitter.
         - Parameter expiration: The `Task`'s expiration time.
         - Parameter dispatcher: The `Dispatcher` to send the `Action` to.
         - Parameter method: The method of dispatching the `Action`.

         - Returns: A `Cancellable` instance.
    */
    public func dispatch<A: EmptyAction>(_ action: A.Type,
                                         expiration: Task.Expiration = .long,
                                         on dispatcher: Dispatcher,
                                         method dispatchMethod: Dispatcher.DispatchMode.UI = .async)
        -> Cancellable {
            let subscription = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        let action = A(task: .requestFailure(error))
                        dispatcher.dispatch(action, mode: dispatchMethod)
                    case .finished:
                        let action = A(task: .requestSuccess(expiration))
                        dispatcher.dispatch(action, mode: dispatchMethod)
                    }
                },
                receiveValue: { value in
                    #if DEBUG
                    fatalError("Received \(value) over a EmptyAction dispatch.")
                    #endif
                }
            )
            return subscription
    }
}
