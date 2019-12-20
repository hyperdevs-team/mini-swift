@testable import Mini
import XCTest

final class ActionTests: XCTestCase {
    func test_action_tag() {
        let action = SetCounterAction(counter: 1)
        
        XCTAssertEqual(String(describing: type(of: action)), SetCounterAction.tag)
    }
}
