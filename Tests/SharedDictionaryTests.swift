@testable import Mini
import XCTest

class SharedDictionaryTests: XCTestCase {
    func test_init() {
        let sharedDictionary = SharedDictionary<String, Int>()

        XCTAssertEqual(sharedDictionary.innerDictionary, [:])
    }

    func test_getorput() {
        let sharedDictionary = SharedDictionary<String, Int>()

        let value = sharedDictionary.safeValue("a") { 4 }

        XCTAssertEqual(value, sharedDictionary.value(withKey: "a"))
        XCTAssertEqual(sharedDictionary.innerDictionary, ["a": 4])
    }
}
