import Combine
import Foundation

public extension Publisher {
    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: TaskExpiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure, Output == None {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error), key: key)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration, tag: "\(key)"), key: key)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: KeyedEmptyAction>(action: A.Type,
                                       expiration: TaskExpiration = .immediately,
                                       key: A.Key,
                                       on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == None, A.TaskError == Failure, Output == Void {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error), key: key)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration, tag: "\(key)"), key: key)
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
                let action = A(task: .failure(error))
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration))
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: EmptyAction>(action: A.Type,
                                  expiration: TaskExpiration = .immediately,
                                  on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == None, A.TaskError == Failure, Output == Void {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error))
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration))
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: AttributedEmptyAction>(action: A.Type,
                                            attribute: A.Attribute,
                                            expiration: TaskExpiration = .immediately,
                                            on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == Output, A.TaskError == Failure, Output == None {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error), attribute: attribute)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration), attribute: attribute)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }

    func dispatch<A: AttributedEmptyAction>(action: A.Type,
                                            attribute: A.Attribute,
                                            expiration: TaskExpiration = .immediately,
                                            on dispatcher: Dispatcher)
    -> Cancellable where A.TaskPayload == None, A.TaskError == Failure, Output == Void {
        sink { completion in
            switch completion {
            case .failure(let error):
                let action = A(task: .failure(error), attribute: attribute)
                dispatcher.dispatch(action)

            case .finished:
                let action = A(task: .success(expiration: expiration), attribute: attribute)
                dispatcher.dispatch(action)
            }
        } receiveValue: { _ in
        }
    }
}
