@testable import Mini
import XCTest

final class DispatcherSubscriptionTests: XCTestCase {
    func test_hashable() {
        let dispatcher = Dispatcher()

        let one = DispatcherSubscription(dispatcher: dispatcher,
                                         id: 1,
                                         priority: 2,
                                         tag: "one") { _ in }
        let two = DispatcherSubscription(dispatcher: dispatcher,
                                         id: 2,
                                         priority: 2,
                                         tag: "two") { _ in }

        let dict: [DispatcherSubscription: Int] = [one: 1, two: 2]

        XCTAssertEqual(dict[one], 1)
        XCTAssertEqual(dict[two], 2)
    }

    func test_comparable() {
        let dispatcher = Dispatcher()

        let one = DispatcherSubscription(dispatcher: dispatcher,
                                         id: 1,
                                         priority: 2,
                                         tag: "one") { _ in }
        let two = DispatcherSubscription(dispatcher: dispatcher,
                                         id: 2,
                                         priority: 2,
                                         tag: "two") { _ in }
        let three = DispatcherSubscription(dispatcher: dispatcher,
                                           id: 3,
                                           priority: 1,
                                           tag: "three") { _ in }

        XCTAssertEqual(one, one)
        XCTAssertNotEqual(one, two)
        XCTAssertNotEqual(one, three)
        XCTAssertTrue(one >= two)
        XCTAssertFalse(one <= three)
        XCTAssertTrue(one > three)
        XCTAssertTrue(three < two)
    }
}
