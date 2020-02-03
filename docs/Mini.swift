import Foundation
import NIOConcurrencyHelpers
import RxSwift
import SwiftOnoneSupport

/**
 Protocol that has to be conformed by any object that can be dispatcher
 by a `Dispatcher` object.
 */
public protocol Action {}

extension Action {
    /// String used as tag of the given Action based on his name.
    /// - Returns: The name of the action as a String.
    public var innerTag: String { get }
}

public protocol Chain {
    var proceed: Mini.Next { get }
}

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

    public func add(middleware: Mini.Middleware)

    public func remove(middleware: Mini.Middleware)

    public func register(service: Mini.Service)

    public func unregister(service: Mini.Service)

    public func subscribe(priority: Int, tag: String, completion: @escaping (Mini.Action) -> Void) -> Mini.DispatcherSubscription

    public func registerInternal(subscription: Mini.DispatcherSubscription) -> Mini.DispatcherSubscription

    public func unregisterInternal(subscription: Mini.DispatcherSubscription)

    public func subscribe<T>(completion: @escaping (T) -> Void) -> Mini.DispatcherSubscription where T: Mini.Action

    public func subscribe<T>(tag: String, completion: @escaping (T) -> Void) -> Mini.DispatcherSubscription where T: Mini.Action

    public func subscribe(tag: String, completion: @escaping (Mini.Action) -> Void) -> Mini.DispatcherSubscription

    public func dispatch(_ action: Mini.Action, mode: Mini.Dispatcher.DispatchMode.UI)
}

public final class DispatcherSubscription: Comparable, RxSwift.Disposable {
    public let id: Int

    public let tag: String

    public init(dispatcher: Mini.Dispatcher, id: Int, priority: Int, tag: String, completion: @escaping (Mini.Action) -> Void)

    /// Dispose resource.
    public func dispose()

    public func on(_ action: Mini.Action)

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Mini.DispatcherSubscription, rhs: Mini.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func > (lhs: Mini.DispatcherSubscription, rhs: Mini.DispatcherSubscription) -> Bool

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
    public static func < (lhs: Mini.DispatcherSubscription, rhs: Mini.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func >= (lhs: Mini.DispatcherSubscription, rhs: Mini.DispatcherSubscription) -> Bool

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func <= (lhs: Mini.DispatcherSubscription, rhs: Mini.DispatcherSubscription) -> Bool
}

public final class ForwardingChain: Mini.Chain {
    public var proceed: Mini.Next { get }

    public init(next: @escaping Mini.Next)
}

public protocol Group: RxSwift.Disposable {
    var disposeBag: RxSwift.CompositeDisposable { get }
}

public protocol Middleware {
    var id: UUID { get }

    var perform: Mini.MiddlewareChain { get }
}

public typealias MiddlewareChain = (Mini.Action, Mini.Chain) -> Mini.Action

public typealias Next = (Mini.Action) -> Mini.Action

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

/**
 The `Reducer` defines the behavior to be executed when a certain
 `Action` object is received.
 */
public class Reducer<A>: RxSwift.Disposable where A: Mini.Action {
    /// The `Action` type which the `Reducer` listens to.
    public let action: A.Type

    /// The `Dispatcher` object that sends the `Action` objects.
    public let dispatcher: Mini.Dispatcher

    /// The behavior to be executed when the `Dispatcher` sends a certain `Action`
    public let reducer: (A) -> Void

    /**
     Initializes a new `Reducer` object.
     - Parameter action: The `Action` type that will be listened to.
     - Parameter dispatcher: The `Dispatcher` that sends the `Action`.
     - Parameter reducer: The closure that will be executed when the `Dispatcher`
     sends the defined `Action` type.
     */
    public init(of action: A.Type, on dispatcher: Mini.Dispatcher, reducer: @escaping (A) -> Void)

    /// Dispose resource.
    public func dispose()
}

public class ReducerGroup: Mini.Group {
    public let disposeBag: RxSwift.CompositeDisposable

    public init(_ builder: RxSwift.Disposable...)

    /// Dispose resource.
    public func dispose()
}

public final class RootChain: Mini.Chain {
    public var proceed: Mini.Next { get }

    public init(map: Mini.SubscriptionMap)
}

public protocol Service {
    var id: UUID { get }

    var perform: Mini.ServiceChain { get }
}

public typealias ServiceChain = (Mini.Action, Mini.Chain) -> Void

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
    func isEqual(to other: Mini.StateType) -> Bool
}

extension StateType where Self: Equatable {
    public func isEqual(to other: Mini.StateType) -> Bool
}

public class Store<State, StoreController>: RxSwift.ObservableType, Mini.StoreType where State: Mini.StateType, StoreController: RxSwift.Disposable {
    /// Type of elements in sequence.
    public typealias Element = State

    public typealias State = State

    public typealias StoreController = StoreController

    public typealias ObjectWillChangePublisher = RxSwift.BehaviorSubject<State>

    public var objectWillChange: RxSwift.BehaviorSubject<State>

    public let dispatcher: Mini.Dispatcher

    public var storeController: StoreController

    public var state: State

    public var initialState: State { get }

    public init(_ state: State, dispatcher: Mini.Dispatcher, storeController: StoreController)

    public var reducerGroup: Mini.ReducerGroup { get }

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

extension Store {
    public func replaying() -> RxSwift.Observable<Mini.Store<State, StoreController>.State>
}

extension Store {
    public func dispatch<A>(_ action: @autoclosure @escaping () -> A) -> RxSwift.Observable<Mini.Store<State, StoreController>.State> where A: Mini.Action

    public func withStateChanges<T>(in stateComponent: @autoclosure @escaping () -> KeyPath<Mini.Store<State, StoreController>.Element, T>) -> RxSwift.Observable<T>
}

public protocol StoreType {
    associatedtype State: Mini.StateType

    associatedtype StoreController: RxSwift.Disposable

    var state: Self.State { get set }

    var dispatcher: Mini.Dispatcher { get }

    var reducerGroup: Mini.ReducerGroup { get }

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
    public var reducerGroup: Mini.ReducerGroup { get }
}

public typealias SubscriptionMap = Mini.SharedDictionary<String, Mini.OrderedSet<Mini.DispatcherSubscription>?>

public prefix func ^ <Root, Value>(keypath: KeyPath<Root, Value>) -> (Root) -> Value

extension Dictionary {
    /// Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
    /// puts its result into the map under the given key and returns it.
    public mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value

    public subscript(_: Key, orPut _: @autoclosure () -> Value) -> Value { mutating get }

    public subscript(unwrapping _: Key) -> Value! { get }
}

extension ObservableType {
    /// Take the first element that matches the filter function.
    ///
    /// - Parameter fn: Filter closure.
    /// - Returns: The first element that matches the filter.
    public func filterOne(_ condition: @escaping (Self.Element) -> Bool) -> RxSwift.Observable<Self.Element>

    public func filter(_ keyPath: KeyPath<Self.Element, Bool>) -> RxSwift.Observable<Self.Element>

    public func map<T>(_ keyPath: KeyPath<Self.Element, T>) -> RxSwift.Observable<T>

    public func one() -> RxSwift.Observable<Self.Element>
}

extension ObservableType where Self.Element: Mini.StateType {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    public func withStateChanges<T>(in stateComponent: @autoclosure @escaping () -> KeyPath<Self.Element, T>, that componentProperty: @autoclosure @escaping () -> KeyPath<T, Bool>) -> RxSwift.Observable<T>
}

prefix operator ^
