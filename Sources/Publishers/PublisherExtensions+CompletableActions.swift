import Combine
import Foundation

public extension Publisher {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        expiration: TaskExpiration = .immediately,
                                        on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error))
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let action = A(task: .success(payload, expiration: expiration))
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
                let action = A(task: .failure(error, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let action = A(task: .success(payload, tag: "\(key)"), key: key)
            dispatcher.dispatch(action)
        }
    }

    func dispatch<A: AttributedCompletableAction>(action: A.Type,
                                                  attribute: A.Attribute,
                                                  expiration: TaskExpiration = .immediately,
                                                  on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error), attribute: attribute)
                dispatcher.dispatch(action)

            case .finished:
                break
            }
        } receiveValue: { payload in
            let action = A(task: .success(payload, expiration: expiration), attribute: attribute)
            dispatcher.dispatch(action)
        }
    }
}
