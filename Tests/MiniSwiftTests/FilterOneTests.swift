import Combine
import XCTest
@testable import MiniSwift

final class FilterOneTests: XCTestCase {
    
    func test_filter_one() {
        
        let cancellableBag = CancellableBag()
        
        let expec = expectation(description: "FilterOne")

        var values = [Int]()

        [1, 2, 3]
            .publisher
            .filterOne { $0 == 2 }
            .sink(
                receiveCompletion: { _ in expec.fulfill() },
                receiveValue: {
                    values.append($0)
            })
            .cancelled(by: cancellableBag)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(values, [2])

    }
}
