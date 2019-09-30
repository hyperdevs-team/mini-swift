import Dispatch
import Foundation
import NIOConcurrencyHelpers
import RxSwift
import SwiftOnoneSupport

public protocol Action {
    func isEqual(to other: MiniSwift.Action) -> Bool
}

extension Action {
    /// String used as tag of the given Action based on his name.
    /// - Returns: The name of the action as a String.
    public var innerTag: String { get }
}

extension Action {
    public static func == (lhs: Self, rhs: Self) -> Bool
}

extension Action where Self: Equatable {
    public func isEqual(to other: MiniSwift.Action) -> Bool
}

public protocol Chain {
    var proceed: MiniSwift.Next { get }
}

public protocol CompletableAction: MiniSwift.Action, MiniSwift.PayloadAction {}

public final class Dispatcher {
    public struct DispatchMode {
        public enum UI {
            case sync

            case async
        }
    }

    public var subscriptionCount: Int { get }

    public static let defaultPriority: Int

    public init()

    public func add(middleware: MiniSwift.Middleware)

    public func remove(middleware: MiniSwift.Middleware)

    public func register(service: MiniSwift.Service)

    public func unregister(service: MiniSwift.Service)

    public func subscribe(priority: Int, tag: String, completion: @escaping (MiniSwift.Action) -> Void) -> MiniSwift.DispatcherSubscription

    public func registerInternal(subscription: MiniSwift.DispatcherSubscription) -> MiniSwift.DispatcherSubscription

    public func unregisterInternal(subscription: MiniSwift.DispatcherSubscription)

    public func subscribe<T>(completion: @escaping (T) -> Void) -> MiniSwift.DispatcherSubscription where T: MiniSwift.Action

    public func subscribe<T>(tag: String, completion: @escaping (T) -> Void) -> MiniSwift.DispatcherSubscription where T: MiniSwift.Action

    public func subscribe(tag: String, completion: @escaping (MiniSwift.Action) -> Void) -> MiniSwift.DispatcherSubscription

    public func dispatch(_ action: MiniSwift.Action, mode: MiniSwift.Dispatcher.DispatchMode.UI)
}

public final class DispatcherSubscription: Comparable, RxSwift.Disposable {
    public let id: Int

    public let tag: String

    public init(dispatcher: MiniSwift.Dispatcher, id: Int, priority: Int, tag: String, completion: @escaping (MiniSwift.Action) -> Void)

    /// Dispose resource.
    public func dispose()

    public func on(_ action: MiniSwift.Action)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: MiniSwift.DispatcherSubscription, rhs: MiniSwift.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func > (lhs: MiniSwift.DispatcherSubscription, rhs: MiniSwift.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: MiniSwift.DispatcherSubscription, rhs: MiniSwift.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func >= (lhs: MiniSwift.DispatcherSubscription, rhs: MiniSwift.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func <= (lhs: MiniSwift.DispatcherSubscription, rhs: MiniSwift.DispatcherSubscription) -> Bool
}

public protocol EmptyAction: MiniSwift.Action, MiniSwift.PayloadAction where Self.Payload == Never {
    init(promise: MiniSwift.Promise<Void>)
}

extension EmptyAction {
    public init(promise: MiniSwift.Promise<Self.Payload?>)
}

public final class ForwardingChain: MiniSwift.Chain {
    public var proceed: MiniSwift.Next { get }

    public init(next: @escaping MiniSwift.Next)
}

public protocol Group: RxSwift.Disposable {
    var disposeBag: RxSwift.CompositeDisposable { get }
}

public protocol KeyedCompletableAction: MiniSwift.Action, MiniSwift.KeyedPayloadAction {}

public protocol KeyedPayloadAction {
    associatedtype Payload

    associatedtype Key: Hashable

    init(promise: [Self.Key: MiniSwift.Promise<Self.Payload?>])
}

public class LoggingService: MiniSwift.Service {
    public var id: UUID

    public var perform: MiniSwift.ServiceChain { get }

    public init()
}

public protocol Middleware {
    var id: UUID { get }

    var perform: MiniSwift.MiddlewareChain { get }
}

public typealias MiddlewareChain = (MiniSwift.Action, MiniSwift.Chain) -> MiniSwift.Action

public typealias Next = (MiniSwift.Action) -> MiniSwift.Action

/**
 An Ordered Set is a collection where all items in the set follow an ordering,
 usually ordered from 'least' to 'most'. The way you value and compare items
 can be user-defined.
 */
public class OrderedSet<T> where T: Comparable {
    public init(initial: [T] = [])

    /// Returns the number of elements in the OrderedSet.
    public var count: Int { get }

    /// Inserts an item. Performance: O(n)
    public func insert(_ item: T) -> Bool

    /// Insert an array of items
    public func insert(_ items: [T]) -> Bool

    /// Removes an item if it exists. Performance: O(n)
    public func remove(_ item: T) -> Bool

    /// Returns true if and only if the item exists somewhere in the set.
    public func exists(_ item: T) -> Bool

    /// Returns the index of an item if it exists, or nil otherwise.
    public func indexOf(_ item: T) -> Int?

    /// Returns the item at the given index.
    /// Assertion fails if the index is out of the range of [0, count).
    public subscript(_: Int) -> T { get }

    /// Returns the 'maximum' or 'largest' value in the set.
    public var max: T? { get }

    /// Returns the 'minimum' or 'smallest' value in the set.
    public var min: T? { get }

    /// Returns the k-th largest element in the set, if k is in the range
    /// [1, count]. Returns nil otherwise.
    public func kLargest(element: Int) -> T?

    /// Returns the k-th smallest element in the set, if k is in the range
    /// [1, count]. Returns nil otherwise.
    public func kSmallest(element: Int) -> T?

    /// For each function
    public func forEach(_ body: (T) -> Void)

    /// Enumerated function
    public func enumerated() -> EnumeratedSequence<[T]>
}

public protocol PayloadAction {
    associatedtype Payload

    init(promise: MiniSwift.Promise<Self.Payload?>)
}

@dynamicMemberLookup public final class Promise<T>: MiniSwift.PromiseType {
    public typealias Element = T

    public class func value(_ value: T) -> MiniSwift.Promise<T>

    public class func error(_ error: Error) -> MiniSwift.Promise<T>

    public init(error: Error)

    public init()

    public class func idle(with options: [String: Any] = [:]) -> MiniSwift.Promise<T>

    public class func pending(options: [String: Any] = [:]) -> MiniSwift.Promise<T>

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

    public subscript<T>(dynamicMember member: String) -> T?
}

extension Promise {
    /**
     - Returns: `true` if the promise has been triggered from some source to its resolution.
     */
    public var isOnProgress: Bool { get }

    /**
     - Returns: `true` if the promise has not yet resolved nor pending.
     */
    public var isIdle: Bool { get }

    /**
     - Returns: `true` if the promise has not yet resolved.
     */
    public var isPending: Bool { get }

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
    public static func == (lhs: MiniSwift.Promise<T>, rhs: MiniSwift.Promise<T>) -> Bool
}

extension Promise where T: Equatable {
    public static func == (lhs: MiniSwift.Promise<T>, rhs: MiniSwift.Promise<T>) -> Bool
}

extension Promise {
    public func notify<T>(to store: T) where T: MiniSwift.StoreType
}

public protocol PromiseType {
    associatedtype Element

    var result: Result<Self.Element, Error>? { get }

    var isIdle: Bool { get }

    var isPending: Bool { get }

    var isResolved: Bool { get }

    var isFulfilled: Bool { get }

    var isRejected: Bool { get }

    var isOnProgress: Bool { get }

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

        case forever(ignoringOld: Bool)
    }
}

public class Reducer<A>: RxSwift.Disposable where A: MiniSwift.Action {
    public let action: A.Type

    public let dispatcher: MiniSwift.Dispatcher

    public let reducer: (A) -> Void

    public init(of action: A.Type, on dispatcher: MiniSwift.Dispatcher, reducer: @escaping (A) -> Void)

    /// Dispose resource.
    public func dispose()
}

public class ReducerGroup: MiniSwift.Group {
    public let disposeBag: RxSwift.CompositeDisposable

    public init(_ builder: RxSwift.Disposable...)

    /// Dispose resource.
    public func dispose()
}

public final class RootChain: MiniSwift.Chain {
    public var proceed: MiniSwift.Next { get }

    public init(map: MiniSwift.SubscriptionMap)
}

public protocol Service {
    var id: UUID { get }

    var perform: MiniSwift.ServiceChain { get }
}

public typealias ServiceChain = (MiniSwift.Action, MiniSwift.Chain) -> Void

/// Wrapper class to allow pass dictionaries with a memory reference
public class SharedDictionary<Key, Value> where Key: Hashable {
    public var innerDictionary: [Key: Value]

    public init()

    public func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value

    public func get(withKey key: Key) -> Value?

    public subscript(_: Key, orPut _: @autoclosure () -> Value) -> Value { get }

    public subscript(_: Key) -> Value? { get }
}

public protocol StateType {
    func isEqual(to other: MiniSwift.StateType) -> Bool
}

extension StateType where Self: Equatable {
    public func isEqual(to other: MiniSwift.StateType) -> Bool
}

public class Store<State, StoreController>: RxSwift.ObservableType, MiniSwift.StoreType where State: MiniSwift.StateType, StoreController: RxSwift.Disposable {
    /// Type of elements in sequence.
    public typealias Element = State

    public typealias State = State

    public typealias StoreController = StoreController

    public typealias ObjectWillChangePublisher = RxSwift.BehaviorSubject<State>

    public var objectWillChange: RxSwift.BehaviorSubject<State>

    public let dispatcher: MiniSwift.Dispatcher

    public var storeController: StoreController

    public var state: State

    public var initialState: State { get }

    public init(_ state: State, dispatcher: MiniSwift.Dispatcher, storeController: StoreController)

    public var reducerGroup: MiniSwift.ReducerGroup { get }

    public func notify()

    public func replayOnce()

    public func reset()

    /**
     Subscribes `observer` to receive events for this sequence.

     ### Grammar

     **Next\* (Error | Completed)?**

     * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
     * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements

     It is possible that events are sent from different threads, but no two events can be sent concurrently to
     `observer`.

     ### Resource Management

     When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
     will be freed.

     To cancel production of sequence elements and free resources immediately, call `dispose` on returned
     subscription.

     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    public func subscribe<Observer>(_ observer: Observer) -> RxSwift.Disposable where State == Observer.Element, Observer: RxSwift.ObserverType
}

public protocol StoreType {
    associatedtype State: MiniSwift.StateType

    associatedtype StoreController: RxSwift.Disposable

    var state: Self.State { get set }

    var dispatcher: MiniSwift.Dispatcher { get }

    var reducerGroup: MiniSwift.ReducerGroup { get }

    func replayOnce()
}

extension StoreType {
    /**
     Property responsible of reduce the `State` given a certain `Action` being triggered.
     ```
     public var reducerGroup: ReducerGroup {
        ReducerGroup {[
            Reducer(of: SomeAction.self, on: self.dispatcher) { (action: SomeAction)
                self.state = myCoolNewState
            },
            Reducer(of: OtherAction.self, on: self.dispatcher) { (action: OtherAction)
                // Needed work
                self.state = myAnotherState
                }
            }
        ]}
     ```
     - Note : The property has a default implementation which complies with the @_functionBuilder's current limitations, where no empty blocks can be produced in this iteration.
     */
    public var reducerGroup: MiniSwift.ReducerGroup { get }
}

public typealias SubscriptionMap = MiniSwift.SharedDictionary<String, MiniSwift.OrderedSet<MiniSwift.DispatcherSubscription>?>

/// Interceptor class for testing purposes which mute all the received actions.
public class TestMiddleware: MiniSwift.Middleware {
    public var id: UUID

    public var perform: MiniSwift.MiddlewareChain { get }

    public init()

    /// Check if a given action have been intercepted before by the Middleware.
    ///
    /// - Parameter action: action to be checked
    /// - Returns: returns true if an action with the same params have been intercepted before.
    public func contains(action: MiniSwift.Action) -> Bool

    /// Check for actions of certain type being intercepted.
    ///
    /// - Parameter kind: Action type to be checked against the intercepted actions.
    /// - Returns: Array of actions of `kind` being intercepted.
    public func actions<T>(of kind: T.Type) -> [T] where T: MiniSwift.Action

    /// Clear all the intercepted actions
    public func clear()
}

/// Action for testing purposes.
public class TestOnlyAction: MiniSwift.Action {
    public func isEqual(to other: MiniSwift.Action) -> Bool
}

extension Dictionary {
    /// Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
    /// puts its result into the map under the given key and returns it.
    public mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value

    public subscript(_: Key, orPut _: @autoclosure () -> Value) -> Value { mutating get }

    public subscript(unwrapping _: Key) -> Value! { get }
}

extension Dictionary where Value: MiniSwift.PromiseType {
    public subscript(promise _: Key) -> Value { get }

    public func hasValue(for key: [Key: Value].Key) -> Bool

    public mutating func resolve(with other: [Key: Value]) -> [Key: Value]
}

extension Dictionary where Value: MiniSwift.PromiseType, Value.Element: Equatable {
    public static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool
}

extension DispatchQueue {
    public static var isMain: Bool { get }
}

extension ObservableType {
    /// Take the first element that matches the filter function.
    ///
    /// - Parameter fn: Filter closure.
    /// - Returns: The first element that matches the filter.
    public func filterOne(_ condition: @escaping (Self.Element) -> Bool) -> RxSwift.Observable<Self.Element>
}

extension ObservableType where Self.Element: MiniSwift.StoreType, Self.Element: RxSwift.ObservableType, Self.Element.Element == Self.Element.State {
    public static func dispatch<A, Type, T>(using dispatcher: MiniSwift.Dispatcher, factory action: @autoclosure @escaping () -> A, taskMap: @escaping (Self.Element.State) -> T?, on store: Self.Element, lifetime: MiniSwift.Promises.Lifetime = .once) -> RxSwift.Observable<Self.Element.State> where A: MiniSwift.Action, T: MiniSwift.Promise<Type>

    public static func dispatch<A, K, Type, T>(using dispatcher: MiniSwift.Dispatcher, factory action: @autoclosure @escaping () -> A, key: K, taskMap: @escaping (Self.Element.State) -> [K: T], on store: Self.Element, lifetime: MiniSwift.Promises.Lifetime = .once) -> RxSwift.Observable<Self.Element.State> where A: MiniSwift.Action, K: Hashable, T: MiniSwift.Promise<Type>
}

extension PrimitiveSequenceType where Self: RxSwift.ObservableConvertibleType, Self.Trait == RxSwift.SingleTrait {
    public func dispatch<A>(action: A.Type, on dispatcher: MiniSwift.Dispatcher, mode: MiniSwift.Dispatcher.DispatchMode.UI = .async, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Disposable where A: MiniSwift.CompletableAction, Self.Element == A.Payload

    public func dispatch<A>(action: A.Type, key: A.Key, on dispatcher: MiniSwift.Dispatcher, mode: MiniSwift.Dispatcher.DispatchMode.UI = .async, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Disposable where A: MiniSwift.KeyedCompletableAction, Self.Element == A.Payload

    public func action<A>(_ action: A.Type, fillOnError errorPayload: A.Payload? = nil) -> RxSwift.Single<A> where A: MiniSwift.CompletableAction, Self.Element == A.Payload
}

extension PrimitiveSequenceType where Self.Element == Never, Self.Trait == RxSwift.CompletableTrait {
    public func dispatch<A>(action: A.Type, on dispatcher: MiniSwift.Dispatcher, mode: MiniSwift.Dispatcher.DispatchMode.UI = .async) -> RxSwift.Disposable where A: MiniSwift.EmptyAction

    public func action<A>(_ action: A.Type) -> RxSwift.Single<A> where A: MiniSwift.EmptyAction
}
