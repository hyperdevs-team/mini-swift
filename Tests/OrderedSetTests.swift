@testable import Mini
import XCTest

final class OrderedSetTests: XCTestCase {
    func test_remove() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2, 3])

        XCTAssertTrue(orderedSet.remove(2))

        XCTAssertFalse(orderedSet.exists(2))

        XCTAssertFalse(orderedSet.remove(2))
    }

    func test_insert() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2, 3])

        orderedSet.insert([2, 2])

        XCTAssertEqual(orderedSet.count, 3)

        orderedSet.insert(4)

        XCTAssertEqual(orderedSet.count, 4)
    }

    func test_min_max() {
        let orderedSet = OrderedSet<Int>(initial: [])

        XCTAssertNil(orderedSet.min)
        XCTAssertNil(orderedSet.max)

        orderedSet.insert([1, 2])

        XCTAssertEqual(orderedSet.min, 1)
        XCTAssertEqual(orderedSet.max, 2)
    }

    func test_enumerated() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2])

        var result = [Int]()
        orderedSet.enumerated().forEach { element in
            result.append(element.element)
        }

        XCTAssertEqual(result, [1, 2])
    }

    func test_subscript() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2])
        XCTAssertEqual(orderedSet[0], 1)
    }

    func test_klargest() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertEqual(orderedSet.kLargest(element: 0), nil)
        XCTAssertEqual(orderedSet.kLargest(element: 4), 4)
        XCTAssertEqual(orderedSet.kLargest(element: 3), 5)
        XCTAssertEqual(orderedSet.kLargest(element: 2), 6)
    }

    func test_ksmallest() {
        let orderedSet = OrderedSet<Int>(initial: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertEqual(orderedSet.kSmallest(element: 0), nil)
        XCTAssertEqual(orderedSet.kSmallest(element: 4), 4)
        XCTAssertEqual(orderedSet.kSmallest(element: 3), 3)
        XCTAssertEqual(orderedSet.kSmallest(element: 2), 2)
    }
}
