import XCTest
import Combine
@testable import MiniSwift

public class OneTestAction: Action {

    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? OneTestAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

public struct TestState: StateType {

    public let testTask: Task
    public let counter: Int

    public init(testTask: Task = Task(), counter: Int = 0) {
        self.testTask = testTask
        self.counter = counter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        return true
    }
}

public class TestStoreController: Cancellable {
    public func cancel() {
        // NO-OP
    }
}

extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        ReducerGroup {
            Reducer(of: OneTestAction.self, on: self.dispatcher) { action in
                self.state = TestState(testTask: .requestSuccess(), counter: action.counter)
            }
        }
    }
}

final class MiniSwiftTests: XCTestCase {

    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        var dBag = CancellableBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
        store.reducerGroup
            .subscribe()
            .cancelled(by: dBag)
        XCTAssertTrue(store.state.counter == 0)
        dispatcher.dispatch(
            OneTestAction(counter: 1),
            mode: .sync
        )
        XCTAssertTrue(store.state.counter == 1)
        dBag = CancellableBag()
        store.reducerGroup
            .subscribe()
            .cancelled(by: dBag)
        dispatcher.dispatch(
            OneTestAction(counter: 2),
            mode: .sync
        )
        XCTAssertTrue(store.state.counter == 2)
        store.reset()
        XCTAssertTrue(store.state.counter == 0)
        dispatcher.dispatch(
            OneTestAction(counter: 3),
            mode: .sync
        )
        XCTAssertTrue(store.state.counter == 3)
    }

    static var allTests = [
        ("test_dispatcher_triggers_action_in_reducer_group_reducer",
         test_dispatcher_triggers_action_in_reducer_group_reducer)
    ]
}
