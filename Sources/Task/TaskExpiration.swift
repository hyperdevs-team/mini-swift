import Foundation

public enum TaskExpiration {
    case immediately
    case short
    case long
    case custom(TimeInterval)

    public var value: TimeInterval {
        switch self {
        case .immediately:
            return 0

        case .short:
            return 60

        case .long:
            return 180

        case .custom(let value):
            return value
        }
    }
}
