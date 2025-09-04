public enum TaskStatus<Payload: Equatable, Failure: Error & Equatable>: Equatable, CustomDebugStringConvertible, CustomStringConvertible {
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

    // MARK: - CustomStringConvertible
    public var description: String {
        switch self {
        case .idle:
            return "⚪️ idle"
        case .running:
            return "🌕 Running"
        case .success(let payload):
            return "🟢 Success - payload: \(payload)"
        case .failure(let error):
            return "🔴 Failure - error: \(error)"
        }
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        description
    }
}
