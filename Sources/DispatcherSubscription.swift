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
