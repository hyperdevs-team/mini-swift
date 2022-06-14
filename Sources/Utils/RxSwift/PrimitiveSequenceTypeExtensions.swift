import Foundation
import RxSwift

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: TypedTask<Element>.Expiration = .immediately,
                                        on dispatcher: Dispatcher,
                                        fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = TypedTask(status: .success(payload: payload), expiration: expiration)

                // swiftlint:disable:next explicit_init
                let action = A.init(task: successTask, payload: payload)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                let failedTask = TypedTask<Element>(status: .failure(error: error), error: error)

                // swiftlint:disable:next explicit_init
                let action = A.init(task: failedTask, payload: errorPayload)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: TypedTask<Element>.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                let successTask = TypedTask(status: .success(payload: payload), expiration: expiration, tag: "\(key)")

                // swiftlint:disable:next explicit_init
                let action = A.init(task: successTask, payload: payload, key: key)
                dispatcher.dispatch(action)
            },
            onFailure: { error in
                let failedTask = TypedTask<Element>(status: .failure(error: error), tag: "\(key)", error: error)

                // swiftlint:disable:next explicit_init
                let action = A.init(task: failedTask, payload: errorPayload, key: key)
                dispatcher.dispatch(action)
            }
        )
        return subscription
    }

    func action<A: CompletableAction>(_ action: A.Type,
                                      expiration: TypedTask<Element>.Expiration = .immediately,
                                      fillOnError errorPayload: A.Payload? = nil)
        -> Single<A> where A.Payload == Element {
        Single.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    let successTask = TypedTask(status: .success(payload: payload), expiration: expiration)

                    // swiftlint:disable:next explicit_init
                    let action = A.init(task: successTask, payload: payload)
                    single(.success(action))
                },
                onFailure: { error in
                    let failedTask = TypedTask<Element>(status: .failure(error: error), error: error)

                    // swiftlint:disable:next explicit_init
                    let action = A.init(task: failedTask, payload: errorPayload)
                    single(.success(action))
                }
            )
            return Disposables.create([subscription])
        }
    }
}

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: TypedTask<A.Payload>.Expiration = .immediately,
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
                                       expiration: TypedTask<A.Payload>.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)

            case .error(let error):
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        }
        return subscription
    }

    func action<A: EmptyAction>(_ action: A.Type,
                                expiration: TypedTask<A.Payload>.Expiration = .immediately)
        -> Single<A> {
        Single.create { single in
            let subscription = self.subscribe { event in
                switch event {
                case .completed:
                    let action = A(task: .requestSuccess(expiration), payload: nil)
                    single(.success(action))

                case .error(let error):
                    let action = A(task: .requestFailure(error), payload: nil)
                    single(.success(action))
                }
            }
            return Disposables.create([subscription])
        }
    }
}
