import Foundation
import RxSwift
import MagicPills

public typealias SubscriptionMap = SharedDictionary<String, OrderedSet<DispatcherSubscription>?>

/**
 Hub for sending actions and subscribing.
 Only stores should subscribe to the dispatcher. Note that this class is not thread safe,
 calling it from a background thread will throw an exception.
 */
public class Dispatcher {
    // swiftlint:disable:next type_name
    public struct UI {
        let dispatcher: Dispatcher

        func sync(_ action: Action) {
            if DispatchQueue.isMain {
                self.dispatcher.dispatch(action: action)
            } else {
                DispatchQueue.main.sync {
                    self.dispatcher.dispatch(action: action)
                }
            }
        }

        func async(_ action: Action) {
            DispatchQueue.main.async {
                self.dispatcher.dispatch(action: action)
            }
        }
    }

    // swiftlint:disable:next identifier_name
    public lazy var ui: UI = UI(dispatcher: self)

    public static let defaultPriority = 100

    /// Check the subscriptions of each action and sum all of them
    public var subscriptionCount: Int {
        return subscriptionMap.innerDictionary.mapValues({ set -> Int in
            guard let setValue = set else {
                return 0
            }

            return setValue.count
        }).reduce(0) {
            $0 + $1.value
        }
    }

    public var dispatching: Bool = false
    private var subscriptionCounter: Int = 0
    private var interceptors = [InterceptorWrapper]()
    private let rootChain: Chain
    private let internalQueue = DispatchQueue(label: "Dispatcher")
    private var subscriptionMap = SharedDictionary<String, OrderedSet<DispatcherSubscription>?>()
    private var chain: Chain

    public init() {
        rootChain = RootChain(withMap: subscriptionMap)
        chain = rootChain
    }

    private func buildChain() -> Chain {
        return fold(initial: rootChain, list: interceptors) { (chain: Chain, interceptor: InterceptorWrapper) -> Chain in
            return ForwardingChain { action in
                interceptor.interceptor(action, chain)
            }
        }
    }

    /// Adds an interceptor function to the action interceptor chain.
    public func addInterceptor(interceptor: InterceptorWrapper) {
        internalQueue.sync {
            interceptors.append(interceptor)
            chain = buildChain()
        }
    }

    /// Removes an interceptor function to the action interceptor chain.
    public func removeInterceptor(interceptor: InterceptorWrapper) {
        internalQueue.sync {
            interceptors.remove(interceptor)
            chain = buildChain()
        }
    }

    /// Dispatches an [Action] to all registered subscribers.
    private func dispatch(action: Action) {
        assertOnUiThread()
        internalQueue.sync {
            defer {
                dispatching = false
            }
            if dispatching {
                preconditionFailure(MiniError.alreadyDispatching.message)
            }
            dispatching = true
            _ = chain.proceed(action: action)
        }
    }

    public func subscribe<T: Action>(completion: @escaping (T) -> Void) -> DispatcherSubscription {
        return subscribe(tag: T.tag, completion: { (action: T) -> Void in
            completion(action)
        })
    }

    public func subscribe<T: Action>(tag: String, completion: @escaping (T) -> Void) -> DispatcherSubscription {
        return subscribe(tag: tag, completion: { object in
            if let action = object as? T {
                completion(action)
            } else {
                fatalError("Casting to \(tag) failed")
            }
        })
    }

    public func subscribe(tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription {
        return subscribe(priority: Dispatcher.defaultPriority, tag: tag, completion: completion)
    }

    /// Subscribes to a given [Action] with a given priority
    ///
    /// - Parameters:
    ///   - priority: Subscription priority
    ///   - tag: Class name of the [Action] to subscribe to
    ///   - fn: Function to be called when the action is dispatched
    /// - Returns: A builded DispatcherSubscription
    public func subscribe(priority: Int, tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription {
        let subscription = DispatcherSubscription(
                withDispatcher: self,
                withId: getNewSubscriptionId(),
                withPriority: priority,
                withTag: tag,
                withCompletion: completion)
        return registerInternal(dispatcherSubscription: subscription)
    }

    public func registerInternal(dispatcherSubscription: DispatcherSubscription) -> DispatcherSubscription {
        internalQueue.sync {
            if let map = subscriptionMap.getOrPut(
                    dispatcherSubscription.tag,
                    defaultValue: { OrderedSet<DispatcherSubscription>() }) {
                map.insert(dispatcherSubscription)
            }
        }
        return dispatcherSubscription
    }

    public func unregisterInternal(dispatcherSubscription: DispatcherSubscription) {
        internalQueue.sync {
            let set = subscriptionMap.get(withKey: dispatcherSubscription.tag) as? OrderedSet<DispatcherSubscription>
            var removed = false
            if let setValue = set {
                removed = setValue.remove(dispatcherSubscription)
            }
            if !removed {
                fatalError("Failed to remove dispatcherSubscription, multiple dispose calls?")
            }
        }
    }

    private func getNewSubscriptionId() -> Int {
        internalQueue.sync {
            subscriptionCounter += 1
        }
        return subscriptionCounter
    }
}

/**
 Custom [Disposable] that handles [Dispatcher] subscriptions.
 */
public class DispatcherSubscription: Disposable, Comparable {

    private let dispatcher: Dispatcher
    private let id: Int
    private let priority: Int
    private let completion: (Action) -> Void
    private var subject: PublishSubject<Action>?
    public let tag: String

    public init(withDispatcher dispatcher: Dispatcher,
                withId id: Int, withPriority priority: Int,
                withTag tag: String,
                withCompletion completion: @escaping (Action) -> Void) {

        self.dispatcher = dispatcher
        self.id = id
        self.priority = priority
        self.tag = tag
        self.completion = completion
    }

    public func onAction(action: Action) {
        if let subjectValue = subject,
           subjectValue.isDisposed {

            print("Subscription is disposed but got an action: \(action)")

        } else {

            completion(action)
            subject?.onNext(action)
        }
    }

    public func dispose() {
        dispatcher.unregisterInternal(dispatcherSubscription: self)
        subject?.onCompleted()
    }

    public static func == (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        return lhs.id == rhs.id
    }

    public static func > (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        return lhs.priority > rhs.priority
    }

    public static func < (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        return lhs.priority < rhs.priority
    }

    public static func >= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        return lhs.priority >= rhs.priority
    }

    public static func <= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        return lhs.priority <= rhs.priority
    }
}
