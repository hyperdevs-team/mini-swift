/*
 Copyright [2021] [Hyperdevs]
 
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

public protocol PromiseType {
    associatedtype Element

    var result: Result<Element, Swift.Error>? { get }

    var isIdle: Bool { get }
    var isPending: Bool { get }
    var isResolved: Bool { get }
    var isFulfilled: Bool { get }
    var isRejected: Bool { get }
    var value: Element? { get }
    var error: Swift.Error? { get }

    func resolve(_ result: Result<Element, Swift.Error>?) -> Self?
    func fulfill(_ value: Element) -> Self
    func reject(_ error: Swift.Error) -> Self
}

@dynamicCallable
@dynamicMemberLookup
public final class Promise<T>: PromiseType {
    public typealias Element = T

    private typealias PromiseBox = Box<Result<T, Swift.Error>>

    private var properties: [String: Any] = [:]

    private let box: PromiseBox

    fileprivate init(box: SealedBox<Result<T, Swift.Error>>) {
        self.box = box
    }

    public class func value(_ value: T) -> Promise<T> {
        return Promise(box: SealedBox(value: Result.success(value)))
    }

    public class func error(_ error: Swift.Error) -> Promise<T> {
        return Promise(box: SealedBox(value: Result.failure(error)))
    }

    public init(error: Swift.Error) {
        box = SealedBox(value: Result.failure(error))
    }

    private init(_ sealant: Sealant<Result<T, Swift.Error>>, options: [String: Any] = [:]) {
        box = EmptyBox()
        box.fill(sealant)
        properties = options
    }

    private init(with box: @autoclosure @escaping () -> Box<Result<T, Error>>) {
        self.box = box()
    }

    public init() {
        box = EmptyBox()
    }

    public class func idle(with options: [String: Any] = [:]) -> Promise<T> {
        return Promise<T>(.idle, options: options)
    }

    public class func pending(options: [String: Any] = [:]) -> Promise<T> {
        return Promise<T>(.pending, options: options)
    }

    public var result: Result<T, Swift.Error>? {
        switch box.inspect() {
        case .idle, .pending, .completed:
            return nil
        case let .resolved(result):
            return result
        }
    }

    /// - Note: `fulfill` do not trigger an object reassignment,
    /// so no notifications about it can be triggered. It is recommended
    /// to call the method `notify` afterwards.
    @discardableResult
    public func fulfill(_ value: T) -> Self {
        box.seal(.success(value))
        return self
    }

    /// - Note: `reject` do not trigger an object reassignment,
    /// so no notifications about it can be triggered. It is recommended
    /// to call the method `notify` afterwards.
    @discardableResult
    public func reject(_ error: Swift.Error) -> Self {
        box.seal(.failure(error))
        return self
    }

    /// Resolves the current `Promise` with the optional `Result` parameter.
    /// - Returns: `self` or `nil` if no `result` was not provided.
    /// - Note: The optional parameter and restun value are helpers in order to
    /// make optional chaining in the `Reducer` context.
    @discardableResult
    public func resolve(_ result: Result<T, Error>?) -> Self? {
        if let result = result {
            box.seal(result)
            return self
        }
        return nil
    }

    public subscript<Value>(dynamicMember member: String) -> Value? {
        return properties[member] as? Value
    }

    public func dynamicallyCall<T>(withKeywordArguments args: KeyValuePairs<String, T>) {
        guard let key = args.first?.key, let value = args.first?.value else { return }
        properties[key] = value
    }
}

extension Dictionary where Key: StringProtocol {}

public extension Promise {
    /**
     - Returns: `true` if the promise has not yet resolved nor pending.
     */
    var isIdle: Bool {
        if case .idle = box.inspect() {
            return true
        }
        return false
    }

    /**
     - Returns: `true` if the promise has not yet resolved.
     */
    var isPending: Bool {
        return !isIdle && (result == nil && !isCompleted)
    }

    /**
     - Returns: `true` if the promise has completed.
     */
    var isCompleted: Bool {
        switch box.inspect() {
        case .completed, .resolved:
            return true
        default:
            return false
        }
    }

    /**
     - Returns: `true` if the promise has resolved.
     */
    var isResolved: Bool {
        return !isIdle && !isPending
    }

    /**
     - Returns: `true` if the promise was fulfilled.
     */
    var isFulfilled: Bool {
        return value != nil
    }

    /**
     - Returns: `true` if the promise was rejected.
     */
    var isRejected: Bool {
        return error != nil
    }

    /**
     - Returns: The value with which this promise was fulfilled or `nil` if this promise is pending or rejected.
     */
    var value: T? {
        switch result {
        case .none:
            return nil
        case let .some(.success(value)):
            return value
        case .some(.failure):
            return nil
        }
    }

    /**
     - Returns: The error with which this promise was rejected or `nil` if this promise is pending or fulfilled.
     */
    var error: Swift.Error? {
        switch result {
        case .none:
            return nil
        case .some(.success):
            return nil
        case let .some(.failure(error)):
            return error
        }
    }
}

extension Promise where T == () {
    public convenience init() {
        self.init(box: SealedBox<Result<Void, Error>>(value: .success(())))
    }

    public static func empty() -> Promise<T> {
        self.init()
    }
}

extension Promise: Equatable where T == () {
    public static func == (lhs: Promise<T>, rhs: Promise<T>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension Promise where T: Equatable {
    public static func == (lhs: Promise<T>, rhs: Promise<T>) -> Bool {
        guard lhs.value == rhs.value else { return false }
        guard lhs.isIdle == rhs.isIdle else { return false }
        guard lhs.isResolved == rhs.isResolved else { return false }
        guard lhs.isRejected == rhs.isRejected else { return false }
        guard lhs.isPending == rhs.isPending else { return false }
        guard lhs.isCompleted == rhs.isCompleted else { return false }
        if
            let result1 = lhs.result,
            let result2 = rhs.result {
            if
                case .failure = result1,
                case .failure = result2 {
                return true
            }
            guard
                case let .success(value1) = result1,
                case let .success(value2) = result2 else { return false }
            guard value1 == value2 else { return false }
        }
        return true
    }
}
