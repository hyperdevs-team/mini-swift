import Foundation

public typealias Next = (Action) -> Action

public protocol Chain {
    var proceed: Next { get }
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
