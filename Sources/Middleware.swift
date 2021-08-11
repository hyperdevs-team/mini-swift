import Foundation

public typealias MiddlewareChain = (Action, Chain) -> Action
public typealias Next = (Action) -> Action

public protocol Chain {
    var proceed: Next { get }
}

public protocol Middleware {
    var id: UUID { get }
    var perform: MiddlewareChain { get }
}

public final class ForwardingChain: Chain {
    private let next: Next

    public var proceed: Next {
        { action in
            return self.next(action)
        }
    }

    public init(next: @escaping Next) {
        self.next = next
    }
}

public final class RootChain: Chain {
    private let map: SubscriptionMap

    public var proceed: Next {
        { action in
            if let set = self.map[action.innerTag] {
                set?.forEach { sub in
                    sub.on(action)
                }
            }
            return action
        }
    }

    public init(map: SubscriptionMap) {
        self.map = map
    }
}
