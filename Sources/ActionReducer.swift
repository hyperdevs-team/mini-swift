import Foundation
import RxSwift

public class Reducer<A: Action>: Disposable {
    public let action: A.Type
    public let dispatcher: Dispatcher
    public let reducer: (A) -> Void

    private var disposable: Disposable!

    public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void) {
        self.action = action
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.disposable = build()
    }

    private func build() -> Disposable {
        let disposable = dispatcher.subscribe(tag: action.tag) {
            self.reducer($0)
        }
        return disposable
    }

    public func dispose() {
        disposable.dispose()
    }
}
