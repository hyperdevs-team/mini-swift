import Foundation
import MagicPills

/// Observes, modifies, and potentially short-circuits actions going through the dispatcher.
public typealias Interceptor = (Action, Chain) -> Action

public struct InterceptorWrapper: DefinesPrimaryKey {

    public typealias PrimaryKey = Int

    public var primaryKey: Int {
        return id
    }

    let id: Int
    let interceptor: Interceptor

    init(withId id: Int, withInterceptor interceptor: @escaping Interceptor) {
        self.id = id
        self.interceptor = interceptor
    }
}

///A chain of interceptors. Call [.proceed] with the intercepted action or directly handle it.
public protocol Chain {
    /// Calls the interceptor chain for a given [Action].
    func proceed(action: Action) -> Action
}

/// Implementation of Chain protocol which execute the action on the interceptors.
public class ForwardingChain: Chain {
    public let proceedFun: (Action) -> Action

    public init(withProceed proceedFun: @escaping (Action) -> Action) {
        self.proceedFun = proceedFun
    }

    public func proceed(action: Action) -> Action {
        return proceedFun(action)
    }
}

/**
 Implementation of Chain protocol which iterate through the subscriptionMap to execute the
 Action on the stores subscribed to it.
 */
public class RootChain: Chain {
    private let map: SubscriptionMap

    public init(withMap subscriptionMap: SubscriptionMap) {
        self.map = subscriptionMap
    }

    public func proceed(action: Action) -> Action {
        if let set = map.get(withKey: action.innerTag) {
            set?.forEach { sub in
                sub.onAction(action: action)
            }
        }
        return action
    }
}
