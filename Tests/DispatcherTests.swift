import Combine
@testable import Mini
import XCTest

final class DispatcherTests: XCTestCase {
    func test_subscription_count() {
        let dispatcher = Dispatcher()
        var cancellables = Set<AnyCancellable>()

        XCTAssert(dispatcher.subscriptionCount == 0)

        dispatcher.subscribe { (_: TestAction) -> Void in }.store(in: &cancellables)
        dispatcher.subscribe { (_: TestAction) -> Void in }.store(in: &cancellables)

        XCTAssert(dispatcher.subscriptionCount == 2)

        cancellables.removeAll()

        XCTAssert(dispatcher.subscriptionCount == 0)
    }

    func test_add_remove_service() {
        let expectation = XCTestExpectation(description: "Perform Action check")
        let dispatcher = Dispatcher()
        let service = TestService(onPerfomAction: { expectation.fulfill() })
        dispatcher.register(service: service)

        XCTAssert(service.actions.isEmpty == true)

        dispatcher.dispatch(TestAction(counter: 1))

        wait(for: [expectation], timeout: 5.0)

        XCTAssert(service.actions.count == 1)
        XCTAssert(service.actions.contains { $0 is TestAction } == true)

        dispatcher.unregister(service: service)
        service.actions.removeAll()

        dispatcher.dispatch(TestAction(counter: 1))

        XCTAssert(service.actions.isEmpty == true)
    }

    func test_replay_state() {
        let expectation = XCTestExpectation(description: "Replay state check")
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController())
        let service = TestService(onStateReplayed: { expectation.fulfill() })
        dispatcher.register(service: service)

        store.replayOnce()

        wait(for: [expectation], timeout: 5.0)
    }

    func test_send_completableaction_to_dispatcher_from_future() {
        let dispatcher = Dispatcher()
        let expectedPayload = "hi!"
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<String, TestError> { promise in
            promise(.success(expectedPayload))
        }
        let futureFailure = Future<String, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestCompletableAction) in
                switch action.task.status {
                case .success(let payload):
                    if payload == expectedPayload {
                        expectationSuccess.fulfill()
                    }

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestCompletableAction.self, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestCompletableAction.self, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_keyedcompletableaction_to_dispatcher_from_future() {
        let dispatcher = Dispatcher()
        let expectedPayload = "hi!"
        let expectedKey = "wawa"
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<String, TestError> { promise in
            promise(.success(expectedPayload))
        }
        let futureFailure = Future<String, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestKeyedCompletableAction) in
                switch action.task.status {
                case .success(let payload) where action.key == expectedKey:
                    if payload == expectedPayload {
                        expectationSuccess.fulfill()
                    }

                case .failure(let error) where action.key == expectedKey:
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestKeyedCompletableAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestKeyedCompletableAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_attributedcompletableaction_to_dispatcher_from_future() {
        let dispatcher = Dispatcher()
        let expectedPayload = "hi!"
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<String, TestError> { promise in
            promise(.success(expectedPayload))
        }
        let futureFailure = Future<String, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestAttributedCompletableAction) in
                switch action.task.status {
                case .success(let payload):
                    if payload == expectedPayload {
                        expectationSuccess.fulfill()
                    }

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }

                XCTAssertEqual(action.attribute, "hola")
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestAttributedCompletableAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestAttributedCompletableAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_emptyaction_to_dispatcher_from_none_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<None, TestError> { promise in
            promise(.success(.none))
        }
        let futureFailure = Future<None, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestEmptyAction) in
                switch action.task.status {
                case .success:
                    expectationSuccess.fulfill()

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_emptyaction_to_dispatcher_from_void_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<Void, TestError> { promise in
            promise(.success(()))
        }
        let futureFailure = Future<Void, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestEmptyAction) in
                switch action.task.status {
                case .success:
                    expectationSuccess.fulfill()

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestEmptyAction.self, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_keyedemptyaction_to_dispatcher_from_none_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        let expectedKey = "wawa"
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<None, TestError> { promise in
            promise(.success(.none))
        }
        let futureFailure = Future<None, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestKeyedEmptyAction) in
                switch action.task.status {
                case .success where action.key == expectedKey:
                    expectationSuccess.fulfill()

                case .failure(let error) where action.key == expectedKey:
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestKeyedEmptyAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestKeyedEmptyAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_keyedemptyaction_to_dispatcher_from_void_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        let expectedKey = "wawa"
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<Void, TestError> { promise in
            promise(.success(()))
        }
        let futureFailure = Future<Void, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestKeyedEmptyAction) in
                switch action.task.status {
                case .success where action.key == expectedKey:
                    expectationSuccess.fulfill()

                case .failure(let error) where action.key == expectedKey:
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestKeyedEmptyAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestKeyedEmptyAction.self, key: expectedKey, on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_attributedemptyaction_to_dispatcher_from_none_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<None, TestError> { promise in
            promise(.success(.none))
        }
        let futureFailure = Future<None, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestAttributedEmptyAction) in
                switch action.task.status {
                case .success:
                    expectationSuccess.fulfill()

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }

                XCTAssertEqual(action.attribute, "hola")
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestAttributedEmptyAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestAttributedEmptyAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }

    func test_send_attributedemptyaction_to_dispatcher_from_void_future() {
        let dispatcher = Dispatcher()
        let expectedError = TestError.berenjenaError
        var cancellables = Set<AnyCancellable>()

        let futureSuccess = Future<Void, TestError> { promise in
            promise(.success(()))
        }
        let futureFailure = Future<Void, TestError> { promise in
            promise(.failure(.berenjenaError))
        }

        // CHECK:
        let expectationSuccess = expectation(description: "wait for action dispatched with task success")
        let expectationFailure = expectation(description: "wait for action dispatched with task error")

        dispatcher
            .subscribe { (action: TestAttributedEmptyAction) in
                switch action.task.status {
                case .success:
                    expectationSuccess.fulfill()

                case .failure(let error):
                    if error == expectedError {
                        expectationFailure.fulfill()
                    }

                default:
                    XCTFail("bad action received: \(action)")
                }

                XCTAssertEqual(action.attribute, "hola")
            }
            .store(in: &cancellables)

        // SEND!
        futureSuccess
            .dispatch(action: TestAttributedEmptyAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)
        futureFailure
            .dispatch(action: TestAttributedEmptyAction.self, attribute: "hola", on: dispatcher)
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
    }
}
