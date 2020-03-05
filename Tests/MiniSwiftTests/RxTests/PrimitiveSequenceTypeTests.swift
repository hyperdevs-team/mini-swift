import Foundation
@testable import MiniPromises
@testable import MiniTasks
import Nimble
import RxBlocking
import RxSwift
import RxTest
@testable import TestMiddleware
import XCTest

private func equalAction<A: Action & Equatable>(_ by: A) -> Predicate<A> {
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

    // MARK: - Promises test actions.

    struct PromisesTestCompletableAction: MiniPromises.CompletableAction, Equatable {
        typealias Payload = Int

        let promise: Promise<Payload>

        static func == (lhs: PromisesTestCompletableAction, rhs: PromisesTestCompletableAction) -> Bool {
            lhs.promise == rhs.promise
        }
    }

    struct PromisesTestKeyedCompletableAction: MiniPromises.KeyedCompletableAction, Equatable {
        typealias Payload = Int
        typealias Key = String

        let promise: [Key: Promise<Payload>]

        static func == (lhs: PromisesTestKeyedCompletableAction, rhs: PromisesTestKeyedCompletableAction) -> Bool {
            lhs.promise == rhs.promise
        }
    }

    struct PromisesTestEmptyAction: MiniPromises.EmptyAction, Equatable {
        let promise: Promise<Void>

        static func == (_: PromisesTestEmptyAction, _: PromisesTestEmptyAction) -> Bool {
            true
        }
    }

    // MARK: - Tasks test actions.

    struct TasksTestCompletableAction: MiniTasks.CompletableAction, Equatable {
        typealias Payload = Int

        let task: AnyTask
        let payload: Payload?

        static func == (lhs: TasksTestCompletableAction, rhs: TasksTestCompletableAction) -> Bool {
            lhs.payload == rhs.payload && lhs.task.status == rhs.task.status
        }
    }

    struct TasksTestKeyedCompletableAction: MiniTasks.KeyedCompletableAction, Equatable {
        typealias Payload = Int
        typealias Key = String

        let task: AnyTask
        let payload: Int?
        let key: Key

        static func == (lhs: TasksTestKeyedCompletableAction, rhs: TasksTestKeyedCompletableAction) -> Bool {
            lhs.key == rhs.key && lhs.payload == rhs.payload && lhs.task.status == rhs.task.status
        }
    }

    struct TasksTestEmptyAction: MiniTasks.EmptyAction, Equatable {
        let task: AnyTask

        static func == (lhs: TasksTestEmptyAction, rhs: TasksTestEmptyAction) -> Bool {
            lhs.task.status == rhs.task.status
        }
    }

    // MARK: - Common

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

    // MARK: - Promises tests

    func test_promises_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: PromisesTestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: PromisesTestCompletableAction.self).count
        ).toEventually(be(1))
    }

    func test_promises_completable_action_dispatch_fill_on_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: PromisesTestCompletableAction.self, on: dispatcher, fillOnError: 1)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: PromisesTestCompletableAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: PromisesTestCompletableAction.self).first?.promise.value) == 1
    }

    func test_promises_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: PromisesTestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: PromisesTestCompletableAction.self).count
        ).toEventually(be(1))

        expect(
            self.testMiddleware.action(of: PromisesTestCompletableAction.self) {
                $0.promise == .error(Error.dummy)
            }
        ).toEventually(beTrue())
    }

    func test_promises_keyed_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: PromisesTestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: PromisesTestKeyedCompletableAction.self) {
                    $0.promise == ["hello": .value(1)]
                }
        ).toEventually(beTrue())
    }

    func test_promises_keyed_completable_action_dispatch_fill_on_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: PromisesTestKeyedCompletableAction.self, key: "hello", on: dispatcher, fillOnError: 1)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: PromisesTestKeyedCompletableAction.self) {
                    $0.promise == ["hello": .value(1)]
                }
        ).toEventually(beTrue())
    }

    func test_promises_keyed_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: PromisesTestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: PromisesTestKeyedCompletableAction.self) {
                    $0.promise == ["hello": .error(Error.dummy)]
                }
        ).toEventually(beTrue())
    }

    func test_promises_completable_action_action() throws {
        guard let action =
            try Single
            .just(1)
            .action(PromisesTestCompletableAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(PromisesTestCompletableAction(promise: .value(1))))
    }

    func test_promises_completable_action_action_fill_on_error() throws {
        guard let action =
            try Single
            .error(Error.dummy)
            .action(PromisesTestCompletableAction.self, fillOnError: 1)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(PromisesTestCompletableAction(promise: .value(1))))
    }

    func test_promises_completable_action_action_error() throws {
        guard let action =
            try Single
            .error(Error.dummy)
            .action(PromisesTestCompletableAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(PromisesTestCompletableAction(promise: .error(Error.dummy))))
    }

    func test_promises_empty_action_action() throws {
        guard let action =
            try Completable
            .empty()
            .action(PromisesTestEmptyAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(PromisesTestEmptyAction(promise: .empty())))
    }

    func test_promises_empty_action_action_error() throws {
        guard let action =
            try Completable
            .error(Error.dummy)
            .action(PromisesTestEmptyAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(PromisesTestEmptyAction(promise: .error(Error.dummy))))
    }

    func test_promises_empty_action_dispatch() {
        Completable
            .empty()
            .dispatch(action: PromisesTestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: PromisesTestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: PromisesTestEmptyAction.self).first?.promise.isResolved) == true
    }

    func test_promises_empty_action_dispatch_error() {
        Completable
            .error(Error.dummy)
            .dispatch(action: PromisesTestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: PromisesTestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: PromisesTestEmptyAction.self).first?.promise.isResolved) == true

        expect(self.testMiddleware.actions(of: PromisesTestEmptyAction.self).first?.promise.isCompleted) == true

        expect(self.testMiddleware.actions(of: PromisesTestEmptyAction.self).first?.promise.isRejected) == true
    }

    // MARK: - Tasks tests

    func test_tasks_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: TasksTestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TasksTestCompletableAction.self).count
        ).toEventually(be(1))
    }

    func test_tasks_completable_action_dispatch_fill_on_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TasksTestCompletableAction.self, on: dispatcher, fillOnError: 1)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TasksTestCompletableAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: TasksTestCompletableAction.self).first?.payload) == 1
    }

    func test_tasks_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TasksTestCompletableAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TasksTestCompletableAction.self).count
        ).toEventually(be(1))

        expect(
            self.testMiddleware.action(of: TasksTestCompletableAction.self) {
                $0.task.error as? Error == Error.dummy
            }
        ).toEventually(beTrue())
    }

    func test_tasks_keyed_completable_action_dispatch() {
        Single
            .just(1)
            .dispatch(action: TasksTestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: TasksTestKeyedCompletableAction.self) {
                    $0.payload == 1 && $0.key == "hello" && $0.task.status == .success
                }
        ).toEventually(beTrue())
    }

    func test_tasks_keyed_completable_action_dispatch_fill_on_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TasksTestKeyedCompletableAction.self, key: "hello", on: dispatcher, fillOnError: 1)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: TasksTestKeyedCompletableAction.self) {
                    $0.payload == 1 && $0.key == "hello" && $0.task.status == .success
                }
        ).toEventually(beTrue())
    }

    func test_tasks_keyed_completable_action_dispatch_error() {
        Single
            .error(Error.dummy)
            .dispatch(action: TasksTestKeyedCompletableAction.self, key: "hello", on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware
                .action(of: TasksTestKeyedCompletableAction.self) {
                    $0.payload == nil && $0.key == "hello" && $0.task.status == .error
                }
        ).toEventually(beTrue())
    }

    func test_tasks_completable_action_action() throws {
        guard let action =
            try Single
            .just(1)
            .action(TasksTestCompletableAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TasksTestCompletableAction(task: .success(), payload: 1)))
    }

    func test_tasks_completable_action_action_fill_on_error() throws {
        guard let action =
            try Single
            .error(Error.dummy)
            .action(TasksTestCompletableAction.self, fillOnError: 1)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TasksTestCompletableAction(task: .success(), payload: 1)))
    }

    func test_tasks_completable_action_action_error() throws {
        guard let action =
            try Single
            .error(Error.dummy)
            .action(TasksTestCompletableAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TasksTestCompletableAction(task: .failure(Error.dummy), payload: nil)))
    }

    func test_tasks_empty_action_action() throws {
        guard let action =
            try Completable
            .empty()
            .action(TasksTestEmptyAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TasksTestEmptyAction(task: .success())))
    }

    func test_tasks_empty_action_action_error() throws {
        guard let action =
            try Completable
            .error(Error.dummy)
            .action(TasksTestEmptyAction.self)
            .toBlocking(timeout: 5.0).first() else { fatalError() }

        expect(action).to(equalAction(TasksTestEmptyAction(task: .failure(Error.dummy))))
    }

    func test_tasks_empty_action_dispatch() {
        Completable
            .empty()
            .dispatch(action: TasksTestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TasksTestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: TasksTestEmptyAction.self).first?.task.isCompleted) == true
    }

    func test_tasks_empty_action_dispatch_error() {
        Completable
            .error(Error.dummy)
            .dispatch(action: TasksTestEmptyAction.self, on: dispatcher)
            .disposed(by: disposeBag)

        expect(
            self.testMiddleware.actions(of: TasksTestEmptyAction.self).count
        ).toEventually(be(1))

        expect(self.testMiddleware.actions(of: TasksTestEmptyAction.self).first?.task.isRunning) == false

        expect(self.testMiddleware.actions(of: TasksTestEmptyAction.self).first?.task.isCompleted) == true

        expect(self.testMiddleware.actions(of: TasksTestEmptyAction.self).first?.task.isFailure) == true
    }
}
