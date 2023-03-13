public enum TaskStatus<Payload: Equatable, Failure: Error>: Equatable {
    case idle
    case running
    case success(payload: Payload)
    case failure(error: Failure)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.running, .running):
            return true

        case (.success(let lhsSuccess), .success(let rhsSuccess)):
            return lhsSuccess == rhsSuccess

        // All error must be treated as different.
        case (.failure, .failure):
            return false

        default:
            return false
        }
    }
}
