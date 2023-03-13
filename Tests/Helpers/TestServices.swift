import Foundation
import Mini
import XCTest

class TestService: ServiceType {
    typealias TestServiceCallBack = () -> Void

    func stateWasReplayed(state: StateType) {
        onStateReplayed?()
    }

    var id = UUID()

    var actions = [Action]()

    private let onStateReplayed: TestServiceCallBack?
    private let onPerfomAction: TestServiceCallBack?

    init(onStateReplayed: TestServiceCallBack? = nil,
         onPerfomAction: TestServiceCallBack? = nil) {
        self.onStateReplayed = onStateReplayed
        self.onPerfomAction = onPerfomAction
    }

    var perform: ServiceChain {
        { action, _ -> Void in
            self.actions.append(action)
            self.onPerfomAction?()
        }
    }
}
