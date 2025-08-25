import Combine
import Foundation

extension DispatcherSubscription: Cancellable {
    public func cancel() {
        dispatcher.unregisterInternal(subscription: self)
    }
}
