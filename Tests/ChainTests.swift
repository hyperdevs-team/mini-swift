@testable import Mini
import XCTest

final class ChainTests: XCTestCase {
    func test_forwarding_chain_forwards_action() {
        let forwardingChain = ForwardingChain { action in
            guard let action = action as? TestAction else { fatalError() }
            return TestAction(counter: action.counter + 1)
        }

        let testAction = TestAction(counter: 0)

        XCTAssert(testAction.counter == 0)

        let newAction = forwardingChain.proceed(testAction) as? TestAction

        XCTAssert(newAction?.counter == 1)
    }
}
