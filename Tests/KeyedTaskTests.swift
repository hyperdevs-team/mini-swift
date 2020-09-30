import XCTest
@testable import Mini

class KeyedTaskTests: XCTestCase {
    var tasks: KeyedTask<Int> {
        return [0: Task.requestRunning(),
                1: Task.requestSuccess(),
                2: Task.requestFailure(NSError(domain: "domain", code: 44, userInfo: nil))]
    }
    
    func test_isRunning_inside_a_keyedtask() {
        XCTAssertTrue(tasks.isRunning(key: 0))
        XCTAssertFalse(tasks.isRunning(key: 1))
        XCTAssertFalse(tasks.isRunning(key: 2))
        XCTAssertFalse(tasks.isRunning(key: 3))
    }
    
    func test_isRecentlySucceeded_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 0))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 1))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 2))
        XCTAssertFalse(tasks.isRecentlySucceeded(key: 3))
    }
    
    func test_isTerminal_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isTerminal(key: 0))
        XCTAssertTrue(tasks.isTerminal(key: 1))
        XCTAssertTrue(tasks.isTerminal(key: 2))
        XCTAssertFalse(tasks.isTerminal(key: 3))
    }
    
    func test_isSuccessful_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isSuccessful(key: 0))
        XCTAssertTrue(tasks.isSuccessful(key: 1))
        XCTAssertFalse(tasks.isSuccessful(key: 2))
        XCTAssertFalse(tasks.isSuccessful(key: 3))
    }
    
    func test_isFailure_inside_a_keyedtask() {
        XCTAssertFalse(tasks.isFailure(key: 0))
        XCTAssertFalse(tasks.isFailure(key: 1))
        XCTAssertTrue(tasks.isFailure(key: 2))
        XCTAssertFalse(tasks.isFailure(key: 3))
    }
}
