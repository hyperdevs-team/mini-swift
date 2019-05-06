import Foundation

/// Custom exceptions for the inner Flux error cases.
public enum FluxExceptions: Error {
    case alreadyDispatchingException
    case notOnUiThreadException
    case onUiThreadException
    case dispatchOnWrongThreadException
    var message: String {
        switch self {
        case .alreadyDispatchingException: return "Already dispatching"
        case .notOnUiThreadException: return "This method can only be called from the main application thread"
        case .onUiThreadException: return "This method can can`t be called from the main application thread"
        case .dispatchOnWrongThreadException: return "Can't dispatch actions while reducing state!"
        }
    }
}
