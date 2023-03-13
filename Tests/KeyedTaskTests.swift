@testable import Mini
import XCTest

class KeyedTaskTests: XCTestCase {
    var tasks: KeyedTask<Int, String, Error> {
        [0: .requestRunning(),
         1: .requestSuccess("hi"),
         2: .requestFailure(NSError(domain: "domain", code: 44, userInfo: nil)),
         3: .requestIdle()]
    }

    func test_subscript() {
        XCTAssertTrue(tasks[task: 1]?.payload == "hi")
        XCTAssertEqual(tasks[task: 4], nil)
    }

    func test_hasValue_inside_a_keyedtask() {
        XCTAssertTrue(tasks.hasValue(for: 0))
        XCTAssertTrue(tasks.hasValue(for: 1))
        XCTAssertTrue(tasks.hasValue(for: 2))
        XCTAssertTrue(tasks.hasValue(for: 3))
        XCTAssertFalse(tasks.hasValue(for: 4))
    }

    func test_isIdle_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isIdle(key: 0))
        XCTAssertFalse(tasks.isIdle(key: 1))
        XCTAssertFalse(tasks.isIdle(key: 2))
        XCTAssertTrue(tasks.isIdle(key: 3))
        XCTAssertFalse(tasks.isIdle(key: 4))
    }

    func test_isRunning_inside_a_keyedtask() {
        XCTAssertTrue(tasks.isRunning(key: 0))
        XCTAssertFalse(tasks.isRunning(key: 1))
        XCTAssertFalse(tasks.isRunning(key: 2))
        XCTAssertFalse(tasks.isRunning(key: 3))
        XCTAssertFalse(tasks.isRunning(key: 4))
    }

    func test_isRecentlySucceeded_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 0))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 1))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 2))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 3))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 4))
    }

    func test_isTerminal_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isTerminal(key: 0))
        XCTAssertTrue(tasks.isTerminal(key: 1))
        XCTAssertTrue(tasks.isTerminal(key: 2))
        XCTAssertFalse(tasks.isTerminal(key: 3))
        XCTAssertFalse(tasks.isTerminal(key: 4))
    }

    func test_isSuccessful_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isSuccessful(key: 0))
        XCTAssertTrue(tasks.isSuccessful(key: 1))
        XCTAssertFalse(tasks.isSuccessful(key: 2))
        XCTAssertFalse(tasks.isSuccessful(key: 3))
        XCTAssertFalse(tasks.isSuccessful(key: 4))
    }

    func test_isFailure_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isFailure(key: 0))
        XCTAssertFalse(tasks.isFailure(key: 1))
        XCTAssertTrue(tasks.isFailure(key: 2))
        XCTAssertFalse(tasks.isFailure(key: 3))
        XCTAssertFalse(tasks.isFailure(key: 4))
    }
}
