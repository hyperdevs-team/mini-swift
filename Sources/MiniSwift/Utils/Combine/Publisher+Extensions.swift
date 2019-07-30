//
//  Publisher+Extensions.swift
//
//
//  Created by Jorge Revuelta on 17/07/2019.
//

import Foundation
import Combine

extension Publisher where Output: StateType {

   private func filterForLifetime<Type, T: TypedTask<Type>> (
        taskMap: @escaping ((Self.Output) -> T?),
        lifetime: Task.Lifetime)
        -> AnyPublisher<Output, Failure> {
            switch lifetime {
            case .once:
                return self
                    .filterOne { taskMap($0)?.isTerminal ?? true }
            case .forever(let ignoreOld):
                let date = Date()
                return self
                    .drop(while: {
                        if ignoreOld {
                            if let task = taskMap($0) {
                                return task.started < date
                            }
                            return false
                        } else {
                            return false
                        }
                    })
                    .filter { taskMap($0)?.isTerminal ?? true }
                    .eraseToAnyPublisher()
            }
    }

    private func filterForKeyedLifetime<K: Hashable> (
        key: K,
        taskMap: @escaping ((Self.Output) -> KeyedTask<K>),
        lifetime: Task.Lifetime)
        -> AnyPublisher<Self.Output, Self.Failure> {
            switch lifetime {
            case .once:
                return self
                    .filter { taskMap($0).hasValue(for: key) }
                    .filter { taskMap($0)[task: key].isTerminal }
                    .eraseToAnyPublisher()
            case .forever:
                return self
                    .drop(while: { taskMap($0)[task: key].status == .idle || taskMap($0)[task: key].isTerminal })
                    .filter { taskMap($0).hasValue(for: key) }
                    .filter { taskMap($0)[task: key].isTerminal }
                    .first()
                    .eraseToAnyPublisher()
            }
    }

    func sink<Type, T: TypedTask<Type>> (
        taskMap: @escaping ((Self.Output) -> T?),
        lifetime: Task.Lifetime = .once,
        success: @escaping (Self.Output) -> Void = { _ in },
        error: @escaping (Self.Output) -> Void = { _ in })
        -> AnyCancellable {
        return self.filterForLifetime(taskMap: taskMap, lifetime: lifetime)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { state in
                    if let task = taskMap(state) {
                        if task.isSuccessful {
                            success(state)
                        } else if task.isFailure {
                            error(state)
                        } else {
                            success(state)
                        }
                    }
                }
            )
        }

    func sink<K: Hashable> (
        key: K,
        taskMap: @escaping ((Self.Output) -> KeyedTask<K>),
        lifetime: Task.Lifetime = .once,
        success: @escaping (Self.Output) -> Void = { _ in },
        error: @escaping (Self.Output) -> Void = { _ in })
        -> AnyCancellable {
            return self
                .filterForKeyedLifetime(key: key, taskMap: taskMap, lifetime: lifetime)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { state in
                        let task = taskMap(state)[task: key]
                        if task.isSuccessful {
                            success(state)
                        } else if task.isFailure {
                            error(state)
                        } else {
                            success(state)
                        }
                    }
                )
    }
}

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
        -> AnyCancellable where A.Payload == Self.Output {
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
        -> AnyCancellable where A.Payload == Self.Output {
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
