@testable import Mini
import Nimble
import XCTest

final class DispatchQueueTests: XCTestCase {
    func test_main_queue() {
        var isMain: Bool = false

        DispatchQueue.main.async {
            isMain = DispatchQueue.isMain
        }

        expect(isMain).toEventually(beTrue())
    }
}
