import Combine
import Foundation

public class Reducer<A: Action>: Cancellable {
    public let action: A.Type
    public let dispatcher: Dispatcher
    public let reducer: (A) -> Void

    private var cancellable: Cancellable!

    public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void) {
        self.action = action
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.cancellable = build()
    }

    private func build() -> Cancellable {
        let cancelable = dispatcher.subscribe(tag: action.tag) {
            self.reducer($0)
        }
        return cancelable
    }

    public func cancel() {
        cancellable.cancel()
    }
}
