import Combine
import Foundation

public extension AnyPublisher where Failure: Error {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: TaskExpiration = .immediately,
                                        on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error))
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let action = A(task: .requestSuccess(payload, expiration: expiration))
            dispatcher.dispatch(action)
        }
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             expiration: TaskExpiration = .immediately,
                                             key: A.Key,
                                             on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let action = A(task: .requestSuccess(payload, tag: "\(key)"), key: key)
            dispatcher.dispatch(action)
        }
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: TaskExpiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure, Output == None {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error), key: key)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess(expiration: expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: TaskExpiration = .immediately,
                                  on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure, Output == None {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .requestFailure(error))
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .requestSuccess(expiration: expiration))
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }
}
