public enum TaskStatus<Payload: Equatable, Failure: Error & Equatable>: Equatable {
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

        case (.failure(let lhsFailure), .failure(let rhsFailure)):
            return lhsFailure == rhsFailure

        default:
            return false
        }
    }
}
