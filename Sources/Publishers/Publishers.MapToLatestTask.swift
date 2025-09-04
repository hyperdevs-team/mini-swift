import Combine

public extension Publisher {
    func mapToLatestTask<DownTask>(
        transform: @escaping ((Output.Payload.ID) -> (AnyPublisher<DownTask, Failure>))
    )
    -> AnyPublisher<DownTask, Failure>
    where Output: Taskable, Output.Payload: Identifiable,
          DownTask: Taskable, DownTask.Failure == Output.Failure {
        map { (task: Output) -> AnyPublisher<DownTask, Failure> in
            switch task.status {
            case .success(let payload):
                return transform(payload.id)
                    .removeDuplicates()
                    .eraseToAnyPublisher()

            case .idle:
                return Just(.idle())
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()

            case .running:
                return Just(.running())
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()

            case .failure(error: let error):
                return Just(.failure(error))
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
