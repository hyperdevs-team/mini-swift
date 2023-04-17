import Foundation
import Mini
import XCTest

class TestInterceptor: Interceptor {
    typealias TestInterceptorCallBack = () -> Void

    func stateWasReplayed(state: any State) {
        onStateReplayed?()
    }

    var id = UUID()

    var actions = [Action]()

    private let onStateReplayed: TestInterceptorCallBack?
    private let onPerfomAction: TestInterceptorCallBack?

    init(onStateReplayed: TestInterceptorCallBack? = nil,
         onPerfomAction: TestInterceptorCallBack? = nil) {
        self.onStateReplayed = onStateReplayed
        self.onPerfomAction = onPerfomAction
    }

    var perform: InterceptorChain {
        { action, _ -> Void in
            self.actions.append(action)
            self.onPerfomAction?()
        }
    }
}
