import Foundation

public enum MiniError: Error {
    case alreadyDispatching
    case notOnUiThread
    case onUiThread
    case dispatchOnWrongThread

    var message: String {
        switch self {
        case .alreadyDispatching: return "Already dispatching"
        case .notOnUiThread: return "This method can only be called from the main application thread"
        case .onUiThread: return "This method can can`t be called from the main application thread"
        case .dispatchOnWrongThread: return "Can't dispatch actions while reducing state!"
        }
    }
}
