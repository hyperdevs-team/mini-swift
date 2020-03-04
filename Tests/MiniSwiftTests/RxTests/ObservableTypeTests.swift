@testable import MiniPromises
import Nimble
import RxBlocking
import RxSwift
import RxTest
import XCTest

private func matchPromiseHash<K: Hashable, Type: Equatable>(_ by: [K: Promise<Type>]) -> Predicate<[K: Promise<Type>]> {
    return Predicate { expression in
        guard let dict = try expression.evaluate() else {
            return PredicateResult(status: .fail,
                                   message: .fail("failed evaluating expression"))
        }
        guard dict == by else {
            return PredicateResult(status: .fail,
                                   message: .fail("Dictionary doesn't match"))
        }
        return PredicateResult(status: .matches,
                               message: .expectedTo("expectation fulfilled"))
    }
}

final class ObservableTypeTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    func test_filter_one() {
        let filterOneObserver = scheduler.createObserver(Int.self)

        scheduler.createColdObservable(
            [
                .next(10, 10),
                .next(20, 20),
                .next(30, 30),
                .completed(40),
            ]
        )
        .filterOne { $0 == 20 }
        .subscribe(filterOneObserver)
        .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(filterOneObserver.events, [
            .next(20, 20),
            .completed(20),
        ])
    }

    func test_skipping_next() {
        let skippingNextObserver = scheduler.createObserver(Int.self)

        scheduler.createColdObservable(
            [
                .next(10, 10),
                .next(20, 20),
                .next(30, 30),
                .completed(40),
            ]
        )
        .skippingCurrent()
        .subscribe(skippingNextObserver)
        .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(skippingNextObserver.events, [
            .next(20, 20),
            .next(30, 30),
            .completed(40),
        ])
    }

    func test_dispatch_action_from_store() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        guard let state = try Observable<Store<TestState, TestStoreController>>
            .dispatch(using: dispatcher,
                      factory: SetCounterAction(counter: 1),
                      taskMap: { $0.counter },
                      on: store)
            .toBlocking(timeout: 5.0).first()
        else {
            fatalError()
        }

        XCTAssertTrue(state.counter.isResolved)
        XCTAssertTrue(state.counter.error == nil)
        XCTAssertEqual(state.counter.value, 1)
    }

    func test_dispatch_hashable_action_from_store() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        guard let state = try Observable<Store<TestState, TestStoreController>>
            .dispatch(using: dispatcher,
                      factory: SetCounterHashAction(counter: 1, key: "hello"),
                      key: "hello",
                      taskMap: { $0.hashCounter },
                      on: store)
            .toBlocking(timeout: 5.0).first()
        else {
            fatalError()
        }

        XCTAssertTrue(state.hashCounter[promise: "hello"].isResolved)
        XCTAssertTrue(state.hashCounter[promise: "hello"].error == nil)
        expect(state.hashCounter).to(matchPromiseHash(["hello": Promise<Int>.value(1)]))
    }

    func test_with_state_changes_promise() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        guard let counter = try store
            .dispatch(SetCounterAction(counter: 1))
            .withStateChanges(in: \.counter)
            .skippingCurrent()
            .toBlocking(timeout: 5.0).first() else {
            fatalError()
        }

        XCTAssertTrue(counter.isFulfilled)
        XCTAssertTrue(counter.value == 1)
    }

    func test_with_state_changes_standalone() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        dispatcher.dispatch(SetCounterAction(counter: 1), mode: .sync)

        guard let counter = try store
            .withStateChanges(in: \.counter)
            .skippingCurrent()
            .toBlocking(timeout: 5.0).first() else {
            fatalError()
        }

        XCTAssertTrue(counter.isFulfilled)
        XCTAssertTrue(counter.value == 1)
    }

    func test_select() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        dispatcher.dispatch(SetRawCounterAction(rawCounter: 1), mode: .sync)

        guard let counter = try store
            .select(\.rawCounter)
            .toBlocking(timeout: 5.0).first() else {
            fatalError()
        }

        XCTAssertEqual(counter, 1)
    }

    func test_with_state_changes_task() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .disposed(by: disposeBag)

        dispatcher.dispatch(SetRawCounterAction(rawCounter: 1), mode: .sync)

        guard let counter = try store
            .withStateChanges(in: \.rawCounter, that: \.rawCounterTask)
            .toBlocking(timeout: 5.0).first() else {
            fatalError()
        }

        XCTAssertEqual(counter, 1)
    }
}
