import XCTest
import Combine
@testable import MiniSwift

final class CreateTests: XCTestCase {
    
    func test_performs_closure_action() {
        
        let cancellableBag = CancellableBag()
        
        let expectation = XCTestExpectation(description: "Create")
        
        let c = Publishers.Create<Int, Never> { subscriber -> AnyCancellable in

            let item = DispatchWorkItem {
                _ = subscriber.receive(Int.random(in: 0...10))
                subscriber.receive(completion: .finished)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)

            return AnyCancellable {
                item.cancel()
                expectation.fulfill()
            }
        }
        
        var values: [Int]?
        
        c.collect().sink(receiveValue: { _values in
                values = _values
        })
        .cancelled(by: cancellableBag)
        
        wait(for: [expectation], timeout: 5)

        XCTAssert(values?.count == 1)
    }
}
