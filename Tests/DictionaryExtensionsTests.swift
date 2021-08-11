@testable import Mini
import XCTest

final class DictionaryExtensionsTests: XCTestCase {
    func test_safe_value() {
        var dictionary = ["a": 1, "b": 2]

        dictionary.keys.forEach { key in
            let value = dictionary.safeValue(key) {
                XCTFail("This never been called because key must exists in the dictionary")
                return 3
            }
            XCTAssertEqual(value, dictionary[key])
        }
        XCTAssertEqual(dictionary.keys.count, 2)

        XCTAssertEqual(dictionary.safeValue("c") { 3 }, 3)
        XCTAssertEqual(dictionary.keys.count, 3)
    }

    func test_get_or_put() {
        var dic = [String: Int]()

        XCTAssertEqual(dic.safeValue("foo") { 1 }, 1)
        XCTAssertEqual(["foo": 1], dic)

        dic["bar"] = 2

        XCTAssertEqual(dic.safeValue("bar") { Int.max }, 2)
        XCTAssertEqual(dic.safeValue("bar2") { 3 }, 3)
    }
}
