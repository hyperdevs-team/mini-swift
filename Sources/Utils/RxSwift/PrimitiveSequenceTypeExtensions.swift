import Foundation
import RxSwift

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: Task.Expiration = .immediately,
                                        on dispatcher: Dispatcher,
                                        fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = Task(status: .success, expiration: expiration, data: payload)

                // swiftlint:disable:next explicit_init
                let action = A.init(task: successTask, payload: payload)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error), payload: errorPayload)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: Task.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = Task(status: .success, expiration: expiration, data: payload, tag: "\(key)")

                // swiftlint:disable:next explicit_init
                let action = A.init(task: successTask, payload: payload, key: key)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error, tag: "\(key)"), payload: errorPayload, key: key)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func action<A: CompletableAction>(_ action: A.Type,
                                      expiration: Task.Expiration = .immediately,
                                      fillOnError errorPayload: A.Payload? = nil)
        -> Single<A> where A.Payload == Self.Element {
        Single.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    let successTask = Task(status: .success, expiration: expiration, data: payload)

                    // swiftlint:disable:next explicit_init
                    let action = A.init(task: successTask, payload: payload)
                    single(.success(action))
                },
                onFailure: { error in
                    // swiftlint:disable:next explicit_init
                    let action = A.init(task: .requestFailure(error), payload: errorPayload)
                    single(.success(action))
                }
            )
            return Disposables.create([subscription])
        }
    }
}

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: Task.Expiration = .immediately,
                                  on dispatcher: Dispatcher)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration))
                dispatcher.dispatch(action)

            case .error(let error):
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error))
                dispatcher.dispatch(action)
            }
        }
        return subscription
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: Task.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                let successTask = Task(status: .success, expiration: expiration, tag: "\(key)")

                // swiftlint:disable:next explicit_init
                let action = A.init(task: successTask, key: key)
                dispatcher.dispatch(action)

            case .error(let error):
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error), key: key)
                dispatcher.dispatch(action)
            }
        }
        return subscription
    }

    func action<A: EmptyAction>(_ action: A.Type,
                                expiration: Task.Expiration = .immediately)
        -> Single<A> {
        Single.create { single in
            let subscription = self.subscribe { event in
                switch event {
                case .completed:
                    let action = A(task: Task.requestSuccess(expiration), payload: nil)
                    single(.success(action))

                case .error(let error):
                    let action = A(task: Task.requestFailure(error), payload: nil)
                    single(.success(action))
                }
            }
            return Disposables.create([subscription])
        }
    }
}
