import Foundation
@testable import Mini
import Nimble
import RxBlocking
import RxSwift
import RxTest
@testable import TestMiddleware
import XCTest

func equalAction<A: Action & Equatable>(_ by: A) -> Predicate<A> {
    return Predicate { expression in
        guard let action = try expression.evaluate() else {
            return PredicateResult(status: .fail,
                                   message: .fail("failed evaluating expression"))
        }
        guard action == by else {
            return PredicateResult(status: .fail,
                                   message: .fail("Actions doesn't match"))
        }
        return PredicateResult(status: .matches,
                               message: .expectedTo("expectation fulfilled"))
    }
}

final class PrimitiveSequenceTypeTests: XCTestCase {
    fileprivate enum Error: Swift.Error { case dummy }

    class TestCompletableAction: CompletableAction, Equatable {
        typealias Payload = Int

        let counter: Promise<Payload>

        required init(promise: Promise<Payload>) {
            counter = promise
        }

        static func == (lhs: TestCompletableAction, rhs: TestCompletableAction) -> Bool {
            lhs.counter == rhs.counter
        }
    }

    class TestKeyedCompletableAction: KeyedCompletableAction, Equatable {
        typealias Payload = Int
        typealias Key = String

        let counterMap: [Key: Promise<Payload>]

        required init(promise: [Key: Promise<Payload>]) {
            counterMap = promise
        }

        static func == (lhs: TestKeyedCompletableAction, rhs: TestKeyedCompletableAction) -> Bool {
            lhs.counterMap == rhs.counterMap
        }
    }

    class TestEmptyAction: EmptyAction, Equatable {
        let promise: Promise<Void>

        required init(promise: Promise<Void>) {
            self.promise = promise
        }

        static func == (_: TestEmptyAction, _: TestEmptyAction) -> Bool {
            true
        }
    }

    var dispatcher: Dispatcher!
    var disposeBag: DisposeBag!
    var testMiddleware: TestMiddleware!

    override func setUp() {
        super.setUp()

        dispatcher = Dispatcher()
        disposeBag = DisposeBag()
        testMiddleware = TestMiddleware()
        dispatcher.add(middleware: testMiddleware)
    }

    func test_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: TestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TestCompletableAction.self).count
        ).toEventually(be(1))
    }

    func test_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TestCompletableAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.action(of: TestCompletableAction.self) {
            $0.counter == .error(Error.dummy)
        }
        ).toEventually(beTrue())
    }

    func test_keyed_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: TestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: TestKeyedCompletableAction.self) {
                    $0.counterMap == ["hello": .value(1)]
                }
        ).toEventually(beTrue())
    }

    func test_keyed_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: TestKeyedCompletableAction.self) {
                    $0.counterMap == ["hello": .error(Error.dummy)]
                }
        ).toEventually(beTrue())
    }

    func test_completable_action_action() throws {
        guard let action =
            try Single
            .just(1)
            .action(TestCompletableAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TestCompletableAction(promise: .value(1))))
    }

    func test_empty_action_dispatch() {
        Completable
            .empty()
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: TestEmptyAction.self).first?.promise.isResolved) == true
    }

    func test_empty_action_dispatch_error() {
        Completable
            .error(Error.dummy)
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: TestEmptyAction.self).first?.promise.isResolved) == true

        expect(self.testMiddleware.actions(of: TestEmptyAction.self).first?.promise.isCompleted) == true

        expect(self.testMiddleware.actions(of: TestEmptyAction.self).first?.promise.isRejected) == true
    }
}
