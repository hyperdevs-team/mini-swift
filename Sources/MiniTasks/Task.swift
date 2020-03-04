/*
 Copyright [2019] [BQ]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public typealias AnyTask = TypedTask<Any>
public typealias KeyedTask<K: Hashable> = [K: AnyTask]

@dynamicMemberLookup
public class TypedTask<T>: Equatable {
    public enum Status {
        case idle
        case running
        case success
        case error
    }

    public let status: Status
    public let data: T?
    public let error: Error?
    public let initDate = Date()

    public init(status: Status = .idle,
                data: T? = nil,
                error: Error? = nil) {
        self.status = status
        self.data = data
        self.error = error
    }

    public static func idle() -> AnyTask {
        AnyTask(status: .idle)
    }

    public static func running() -> AnyTask {
        AnyTask(status: .running)
    }

    public static func success<T>(_ data: T? = nil) -> TypedTask<T> {
        TypedTask<T>(status: .success, data: data)
    }

    public static func success() -> AnyTask {
        AnyTask(status: .success)
    }

    public static func failure(_ error: Error) -> AnyTask {
        AnyTask(status: .error, error: error)
    }

    public var isRunning: Bool {
        status == .running
    }

    public var isCompleted: Bool {
        status == .success || status == .error
    }

    public var isSuccessful: Bool {
        status == .success
    }

    public var isFailure: Bool {
        status == .error
    }

    private var properties: [String: Any] = [:]

    public subscript<Value>(dynamicMember member: String) -> Value? {
        get {
            properties[member] as? Value
        }
        set {
            properties[member] = newValue
        }
    }

    public static func == (lhs: TypedTask<T>, rhs: TypedTask<T>) -> Bool {
        lhs.status == rhs.status && lhs.initDate == rhs.initDate
    }
}
