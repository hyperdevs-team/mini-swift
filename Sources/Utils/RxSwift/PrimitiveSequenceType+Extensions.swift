/*
 Copyright [2019] [BQ]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import RxSwift

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {

    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: Task.Expiration = .immediately,
                                        on dispatcher: Dispatcher,
                                        mode: Dispatcher.DispatchMode.UI = .async,
                                        fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration), payload: payload)
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error), payload: errorPayload)
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: Task.Expiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             mode: Dispatcher.DispatchMode.UI = .async,
                                             fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = self.subscribe(
            onSuccess: { payload in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration), payload: payload, key: key)
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error), payload: errorPayload, key: key)
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    func action<A: CompletableAction>(_ action: A.Type,
                                      expiration: Task.Expiration = .immediately,
                                      fillOnError errorPayload: A.Payload? = nil)
        -> Single<A> where A.Payload == Self.Element {
        return Single.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    // swiftlint:disable:next explicit_init
                    let action = A.init(task: .requestSuccess(expiration), payload: payload)
                    single(.success(action))
                },
                onError: { error in
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
                                  on dispatcher: Dispatcher,
                                  mode: Dispatcher.DispatchMode.UI = .async)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration))
                dispatcher.dispatch(action, mode: mode)
            case .error(let error):
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error))
                dispatcher.dispatch(action, mode: mode)
            }
        }
        return subscription
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: Task.Expiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher,
                                       mode: Dispatcher.DispatchMode.UI = .async)
        -> Disposable {
        let subscription = self.subscribe { completable in
            switch completable {
            case .completed:
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestSuccess(expiration), key: key)
                dispatcher.dispatch(action, mode: mode)
            case .error(let error):
                // swiftlint:disable:next explicit_init
                let action = A.init(task: .requestFailure(error), key: key)
                dispatcher.dispatch(action, mode: mode)
            }
        }
        return subscription
    }

    func action<A: EmptyAction>(_ action: A.Type,
                                expiration: Task.Expiration = .immediately)
        -> Single<A> {
        return Single.create { single in
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
