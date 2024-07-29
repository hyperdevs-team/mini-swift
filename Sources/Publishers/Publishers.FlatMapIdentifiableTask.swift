import Combine

public extension Publisher {
    func flatMapIdentifiableTask<NewTask>(
        transform: @escaping ((Output.Payload.ID) -> (AnyPublisher<NewTask, Failure>))
    ) -> AnyPublisher<NewTask, Failure>
    where
        Output: Taskable, Output.Payload: Identifiable, NewTask: Taskable, NewTask.Failure == Output.Failure {
        map { (task: Output) -> AnyPublisher<NewTask, Failure> in
            switch task.status {
            case .success(let payload):
                return transform(payload.id)

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
