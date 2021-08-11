import Foundation

public typealias SubscriptionMap = SharedDictionary<String, OrderedSet<DispatcherSubscription>?>

public final class Dispatcher {
    public struct DispatchMode {
        // swiftlint:disable:next type_name nesting
        public enum UI {
            case sync, async
        }
    }

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
    private var middleware = [Middleware]()
    private var service = [ServiceType]()
    private let root: RootChain
    private var chain: Chain
    private var dispatching = false
    private var subscriptionCounter = 0

    public init() {
        root = RootChain(map: subscriptionMap)
        chain = root
    }

    private func build() -> Chain {
        middleware.reduce(root) { (chain: Chain, middleware: Middleware) -> Chain in
            return ForwardingChain { action in
                middleware.perform(action, chain)
            }
        }
    }

    public func add(middleware: Middleware) {
        internalQueue.sync {
            self.middleware.append(middleware)
            self.chain = build()
        }
    }

    public func remove(middleware: Middleware) {
        internalQueue.sync {
            if let index = self.middleware.firstIndex(where: { middleware.id == $0.id }) {
                self.middleware.remove(at: index)
            }
            chain = build()
        }
    }

    public func register(service: ServiceType) {
        internalQueue.sync {
            self.service.append(service)
        }
    }

    public func unregister(service: ServiceType) {
        internalQueue.sync {
            if let index = self.service.firstIndex(where: { service.id == $0.id }) {
                self.service.remove(at: index)
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
        subscribe(tag: T.tag) { (action: T) -> Void in
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

    @available(*, deprecated, message: "Dont set mode. Use dispatch(_). In the near future all actions will be dispatched asynchronously")
    public func dispatch(_ action: Action, mode: Dispatcher.DispatchMode.UI) {
         switch mode {
         case .sync:
             if DispatchQueue.isMain {
                 self.dispatchOnQueue(action)
             } else {
                 DispatchQueue.main.sync {
                     self.dispatchOnQueue(action)
                 }
             }

         case .async:
             DispatchQueue.main.async {
                 self.dispatchOnQueue(action)
             }
         }
    }

    public func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.dispatchOnQueue(action)
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
                self.service.forEach {
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

public final class DispatcherSubscription: Comparable {
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
