import Foundation
import RxSwift

extension DispatcherSubscription: Disposable {
    public func dispose() {
        dispatcher.unregisterInternal(subscription: self)
    }
}
