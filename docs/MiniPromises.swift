import Dispatch
import Foundation
import Mini
import RxSwift
import SwiftOnoneSupport

public protocol CompletableAction: Mini.Action, MiniPromises.PayloadAction {}

public protocol EmptyAction: Mini.Action, MiniPromises.PayloadAction where Self.Payload == Void {
    init(promise: MiniPromises.Promise<Void>)
}

extension EmptyAction {
    public init(promise _: MiniPromises.Promise<Self.Payload>)
}

public protocol KeyedCompletableAction: Mini.Action, MiniPromises.KeyedPayloadAction {}

public protocol KeyedPayloadAction {
    associatedtype Payload

    associatedtype Key: Hashable

    init(promise: [Self.Key: MiniPromises.Promise<Self.Payload>])
}

public protocol PayloadAction {
    associatedtype Payload

    init(promise: MiniPromises.Promise<Self.Payload>)
}

@dynamicCallable @dynamicMemberLookup public final class Promise<T>: MiniPromises.PromiseType {
    public typealias Element = T

    public class func value(_ value: T) -> MiniPromises.Promise<T>

    public class func error(_ error: Error) -> MiniPromises.Promise<T>

    public init(error: Error)

    public init()

    public class func idle(with options: [String: Any] = [:]) -> MiniPromises.Promise<T>

    public class func pending(options: [String: Any] = [:]) -> MiniPromises.Promise<T>

    public var result: Result<T, Error>? { get }

    /// - Note: `fulfill` do not trigger an object reassignment,
    /// so no notifications about it can be triggered. It is recommended
    /// to call the method `notify` afterwards.
    public func fulfill(_ value: T) -> Self

    /// - Note: `reject` do not trigger an object reassignment,
    /// so no notifications about it can be triggered. It is recommended
    /// to call the method `notify` afterwards.
    public func reject(_ error: Error) -> Self

    /// Resolves the current `Promise` with the optional `Result` parameter.
    /// - Returns: `self` or `nil` if no `result` was not provided.
    /// - Note: The optional parameter and restun value are helpers in order to
    /// make optional chaining in the `Reducer` context.
    public func resolve(_ result: Result<T, Error>?) -> Self?

    public subscript<Value>(dynamicMember _: String) -> Value? { get }

    public func dynamicallyCall<T>(withKeywordArguments args: KeyValuePairs<String, T>)
}

extension Promise {
    /**
     - Returns: `true` if the promise has not yet resolved nor pending.
     */
    public var isIdle: Bool { get }

    /**
     - Returns: `true` if the promise has not yet resolved.
     */
    public var isPending: Bool { get }

    /**
     - Returns: `true` if the promise has completed.
     */
    public var isCompleted: Bool { get }

    /**
     - Returns: `true` if the promise has resolved.
     */
    public var isResolved: Bool { get }

    /**
     - Returns: `true` if the promise was fulfilled.
     */
    public var isFulfilled: Bool { get }

    /**
     - Returns: `true` if the promise was rejected.
     */
    public var isRejected: Bool { get }

    /**
     - Returns: The value with which this promise was fulfilled or `nil` if this promise is pending or rejected.
     */
    public var value: T? { get }

    /**
     - Returns: The error with which this promise was rejected or `nil` if this promise is pending or fulfilled.
     */
    public var error: Error? { get }
}

extension Promise where T == () {
    public convenience init()

    public static func empty() -> MiniPromises.Promise<T>
}

extension Promise: Equatable where T == () {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: MiniPromises.Promise<T>, rhs: MiniPromises.Promise<T>) -> Bool
}

extension Promise where T: Equatable {
    public static func == (lhs: MiniPromises.Promise<T>, rhs: MiniPromises.Promise<T>) -> Bool
}

extension Promise {
    public func notify<T>(to store: T) where T: Mini.StoreType
}

public protocol PromiseType {
    associatedtype Element

    var result: Result<Self.Element, Error>? { get }

    var isIdle: Bool { get }

    var isPending: Bool { get }

    var isResolved: Bool { get }

    var isFulfilled: Bool { get }

    var isRejected: Bool { get }

    var value: Self.Element? { get }

    var error: Error? { get }

    func resolve(_ result: Result<Self.Element, Error>?) -> Self?

    func fulfill(_ value: Self.Element) -> Self

    func reject(_ error: Error) -> Self
}

public enum Promises {}

extension Promises {
    public enum Lifetime {
        case once

        case forever(ignoringOld: Bool = false)
    }
}

extension Dictionary where Value: MiniPromises.PromiseType {
    public subscript(promise _: Key) -> Value { get }

    public func hasValue(for key: [Key: Value].Key) -> Bool

    public func resolve(with other: [Key: Value]) -> [Key: Value]

    public func mergingNew(with other: [Key: Value]) -> [Key: Value]
}

extension Dictionary where Value: MiniPromises.PromiseType, Value.Element: Equatable {
    public static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool
}

extension ObservableType where Self.Element: Mini.StoreType, Self.Element: RxSwift.ObservableType, Self.Element.Element == Self.Element.State {
    @available(*, deprecated, message: "Use store.dispatch() or dispatcher.dispatch in conjunction with an Observable over the Store: withStateChanges, select")
    public static func dispatch<A, Type, T>(using dispatcher: Mini.Dispatcher? = nil, factory action: @autoclosure @escaping () -> A, taskMap: @escaping (Self.Element.State) -> T?, on store: Self.Element, lifetime: MiniPromises.Promises.Lifetime = .once) -> RxSwift.Observable<Self.Element.State> where A: Mini.Action, T: MiniPromises.Promise<Type>

    @available(*, deprecated, message: "Use store.dispatch() or dispatcher.dispatch in conjunction with an Observable over the Store: withStateChanges, select")
    public static func dispatch<A, K, Type, T>(using dispatcher: Mini.Dispatcher? = nil, factory action: @autoclosure @escaping () -> A, key: K, taskMap: @escaping (Self.Element.State) -> [K: T], on store: Self.Element, lifetime: MiniPromises.Promises.Lifetime = .once) -> RxSwift.Observable<Self.Element.State> where A: Mini.Action, K: Hashable, T: MiniPromises.Promise<Type>
}

extension PrimitiveSequenceType where Self: RxSwift.ObservableConvertibleType, Self.Trait == RxSwift.SingleTrait {
    public func dispatch<A>(action: A.Type, on dispatcher: Mini.Dispatcher, mode: Mini.Dispatcher.DispatchMode.UI = .async, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Disposable where A: MiniPromises.CompletableAction, Self.Element == A.Payload

    public func dispatch<A>(action: A.Type, key: A.Key, on dispatcher: Mini.Dispatcher, mode: Mini.Dispatcher.DispatchMode.UI = .async, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Disposable where A: MiniPromises.KeyedCompletableAction, Self.Element == A.Payload

    public func action<A>(_ action: A.Type, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Single<A> where A: MiniPromises.CompletableAction, Self.Element == A.Payload
}

extension PrimitiveSequenceType where Self.Element == Never, Self.Trait == RxSwift.CompletableTrait {
    public func dispatch<A>(action: A.Type, on dispatcher: Mini.Dispatcher, mode: Mini.Dispatcher.DispatchMode.UI = .async) -> RxSwift.Disposable where A: MiniPromises.EmptyAction

    public func action<A>(_ action: A.Type) -> RxSwift.Single<A> where A: MiniPromises.EmptyAction
}
