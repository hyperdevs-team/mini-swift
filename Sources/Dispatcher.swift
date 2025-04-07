import Foundation

public typealias SubscriptionMap = SharedDictionary<String, OrderedSet<DispatcherSubscription>?>

public final class Dispatcher {
    public var subscriptionCount: Int {
        subscriptionMap.innerDictionary.mapValues { set -> Int in
            guard let setValue = set else { return 0 }
            return setValue.count
        }
        .reduce(0) { $0 + $1.value }
    }

    public static let defaultPriority = 100

    private let internalQueue = DispatchQueue(label: "MiniSwift", qos: .userInitiated)
    private var subscriptionMap = SubscriptionMap()
    private var interceptors = [Interceptor]()
    private let root: RootChain
    private var chain: Chain
    private var dispatching = false
    private var subscriptionCounter = 0

    public init() {
        root = RootChain(map: subscriptionMap)
        chain = root
    }

    public func register(interceptor: Interceptor) {
        internalQueue.sync {
            self.interceptors.append(interceptor)
        }
    }

    public func unregister(interceptor: Interceptor) {
        internalQueue.sync {
            if let index = self.interceptors.firstIndex(where: { interceptor.id == $0.id }) {
                self.interceptors.remove(at: index)
            }
        }
    }

    public func subscribe(priority: Int, tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription {
        let subscription = DispatcherSubscription(
            dispatcher: self,
            id: getNewSubscriptionId(),
            priority: priority,
            tag: tag,
            completion: completion)
        return registerInternal(subscription: subscription)
    }

    public func registerInternal(subscription: DispatcherSubscription) -> DispatcherSubscription {
        internalQueue.sync {
            if let map = subscriptionMap[subscription.tag, ifNotExistsSave: OrderedSet<DispatcherSubscription>()] {
                map.insert(subscription)
            }
        }
        return subscription
    }

    public func unregisterInternal(subscription: DispatcherSubscription) {
        internalQueue.sync {
            var removed = false
            if let set = subscriptionMap[subscription.tag] as? OrderedSet<DispatcherSubscription> {
                removed = set.remove(subscription)
            } else {
                removed = true
            }
            assert(removed, "Failed to remove DispatcherSubscription, multiple dispose calls?")
        }
    }

    public func subscribe<T: Action>(completion: @escaping (T) -> Void) -> DispatcherSubscription {
        subscribe(tag: T.tag) { (action: T) in
            completion(action)
        }
    }

    public func subscribe<T: Action>(tag: String, completion: @escaping (T) -> Void) -> DispatcherSubscription {
        subscribe(tag: tag) { object in
            if let action = object as? T {
                completion(action)
            } else {
                fatalError("Casting to \(tag) failed")
            }
        }
    }

    public func subscribe(tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription {
        subscribe(priority: Dispatcher.defaultPriority, tag: tag, completion: completion)
    }

    public func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.dispatchOnQueue(action)
        }
    }

    internal func stateWasReplayed(state: any State) {
        internalQueue.async { [weak self] in
            guard let self = self else { return }
            self.interceptors.forEach {
                $0.stateWasReplayed(state: state)
            }
        }
    }

    private func dispatchOnQueue(_ action: Action) {
        internalQueue.sync {
            defer { dispatching = false }
            if dispatching {
                preconditionFailure("Already dispatching")
            }
            dispatching = true
            _ = chain.proceed(action)
            internalQueue.async { [weak self] in
                guard let self = self else { return }
                self.interceptors.forEach {
                    $0.perform(action, self.chain)
                }
            }
        }
    }

    private func getNewSubscriptionId() -> Int {
        let previous = subscriptionCounter
        subscriptionCounter += 1
        return previous
    }
}

public final class DispatcherSubscription: Comparable, Equatable, Hashable {
    internal let dispatcher: Dispatcher

    public let id: Int
    private let priority: Int
    private let completion: (Action) -> Void

    public let tag: String

    public init (dispatcher: Dispatcher,
                 id: Int,
                 priority: Int,
                 tag: String,
                 completion: @escaping (Action) -> Void) {
        self.dispatcher = dispatcher
        self.id = id
        self.priority = priority
        self.tag = tag
        self.completion = completion
    }

    public func on(_ action: Action) {
        completion(action)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        lhs.id == rhs.id
    }

    public static func > (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        lhs.priority > rhs.priority
    }

    public static func < (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        lhs.priority < rhs.priority
    }

    public static func >= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        lhs.priority >= rhs.priority
    }

    public static func <= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool {
        lhs.priority <= rhs.priority
    }
}
