import XCTest
@testable import Mini

final class DictionaryExtensionsTests: XCTestCase {

    func test_get_or_put() {

        var dic = [String: Int]()

        XCTAssertEqual(dic.getOrPut("foo", defaultValue: 1), 1)
        XCTAssertEqual(["foo": 1], dic)

        dic["bar"] = 2

        XCTAssertEqual(dic.getOrPut("bar", defaultValue: Int.max), 2)
    }

    func test_unrapping_subscript() {

        var dic = [String: Int]()

        let test: Int? = dic[unwrapping: "foo"]

        XCTAssertEqual(test, nil)

        dic["foo"] = 1

        let test2: Int? = dic[unwrapping: "foo"]

        XCTAssertEqual(test2, 1)
    }
}
