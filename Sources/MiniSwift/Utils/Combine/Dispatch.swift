//
//  Dispatch.swift
//  
//
//  Created by Jorge Revuelta on 29/07/2019.
//

import Foundation
import Combine

extension Task {
    public enum Lifetime {
        case once
        case forever(ignoringOld: Bool)
    }
}

extension Publishers {
    
    public struct Dispatch<Store: StoreType & ObservableObject, A: Action, T: Task>: Publisher where Store.ObjectWillChangePublisher: CurrentValueSubject<Store.State, Store.ObjectWillChangePublisher.Failure> {
        
        public typealias Output = Store.State
        
        public typealias Failure = Error
        
        private let dispatcher: Dispatcher
        private let action: () -> A
        private let taskMap: (Store.State) -> T?
        private let store: Store
        private let lifetime: Task.Lifetime
        
        public init(using dispatcher: Dispatcher,
                    factory action: @autoclosure @escaping () -> A,
                    taskMap: @escaping (Store.State) -> T?,
                    on store: Store,
                    lifetime: Task.Lifetime = .once) {
            self.dispatcher = dispatcher
            self.action = action
            self.taskMap = taskMap
            self.store = store
            self.lifetime = lifetime
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, Store.ObjectWillChangePublisher.Output == S.Input {
            let action = self.action()
            self.dispatcher.dispatch(action, mode: .sync)
            let subscription = self.store.objectWillChange.sink(
                taskMap: self.taskMap,
                lifetime: self.lifetime,
                success: { state in
                    _ = subscriber.receive(state)
                },
                error: { state in
                    if let task = self.taskMap(state), let error = task.error {
                        subscriber.receive(completion: .failure(error))
                    }
                }
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

//extension Publisher where Output: StoreType, Output: ObservableObject, Output.ObjectWillChangePublisher: CurrentValueSubject<Output.State, Error> {
//
//    public static func dispatch<A: Action, T: Task>(using dispatcher: Dispatcher,
//                                                    factory action: @autoclosure @escaping () -> A,
//                                                    taskMap: @escaping (Self.Output.State) -> T?,
//                                                    on store: Output,
//                                                    lifetime: Task.Lifetime = .once) -> AnyPublisher<Self.Output.ObjectWillChangePublisher.Output, Self.Output.ObjectWillChangePublisher.Failure> {
//        let publisher = Publishers.Create<Self.Output.ObjectWillChangePublisher.Output, Self.Output.ObjectWillChangePublisher.Failure> { (subscriber: AnySubscriber<Self.Output.State, Error>) -> AnyCancellable in
//            let action = action()
//            dispatcher.dispatch(action, mode: .sync)
//            let subscription: AnyCancellable = store.objectWillChange.sink(
//                taskMap: taskMap,
//                lifetime: lifetime,
//                success: { state in
//                    _ = subscriber.receive(state)
//                },
//                error: { state in
//                    if let task = taskMap(state), let error = task.error {
//                        subscriber.receive(completion: .failure(error))
//                    }
//                }
//            )
//            return subscription
//        }
//        return publisher.eraseToAnyPublisher()
//    }
//}
