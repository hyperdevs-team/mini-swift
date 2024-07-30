import Combine
@testable import Mini
import XCTest

class PublishersTests: XCTestCase {
    static var payload1 = TestPayload(id: "uno", value: 4)
    static var payload2 = TestPayload(id: "dos", value: 6)
    var taskIdentifiableSuccess1: Task<TestPayload, TestError> = .success(payload1)
    var taskIdentifiableSuccess2: Task<TestPayload, TestError> = .success(payload2)
    var taskIdentifiableFailure1: Task<TestPayload, TestError> = .failure(.berenjenaError)
    var taskIdentifiableFailure2: Task<TestPayload, TestError> = .failure(.bigBerenjenaError)
    var taskIdentifiableRunning1: Task<TestPayload, TestError> = .running()
    var taskIdentifiableIdle1: Task<TestPayload, TestError> = .idle()
    func taskSuccess(value: String) -> Task<String, TestError> { .success("success:\(value)") }
    var taskSuccessExpired: Task<String, TestError> = .success("hola viejo", started: Date() - 1_000, expiration: .immediately)
    var taskSuccess1: Task<String, TestError> = .success("hola")
    var taskSuccess2: Task<String, TestError> = .success("chau")
    var taskFailure1: Task<String, TestError> = .failure(.berenjenaError)
    var taskFailureExpired: Task<String, TestError> = .failure(.berenjenaError, started: Date() - 1_000)
    var taskFailure2: Task<String, TestError> = .failure(.bigBerenjenaError)
    var taskRunning1: Task<String, TestError> = .running()
    var taskIdle1: Task<String, TestError> = .idle()
}
