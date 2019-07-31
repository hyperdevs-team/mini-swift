import Combine
import XCTest
@testable import MiniSwift

final class FilterOneTests: XCTestCase {
    
    func test_filter_one() {
        
        let cancellableBag = CancellableBag()

        var values = [Int]()

        [1, 2, 3]
            .publisher
            .filterOne { $0 == 2 }
            .sink(receiveValue: { values.append($0) })
            .cancelled(by: cancellableBag)
        
        XCTAssert(values.count == 1)
        
        XCTAssert(values.first == 2)
    }
}
