//
//  Middleware.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation

public typealias Middleware = (Action, Chain) -> Action
public typealias Next = (Action) -> Action

public protocol Chain {
    var proceed: Next { get }
}

public struct MiddlewareWrapper: Equatable {
    public let id: Int
    // swiftlint:disable:next identifier_name
    public let `do`: Middleware

    public init(id: Int, middleware: @escaping Middleware) {
        self.id = id
        self.do = middleware
    }

    public static func == (lhs: MiddlewareWrapper, rhs: MiddlewareWrapper) -> Bool {
        return lhs.id == lhs.id
    }
}

public final class ForwardingChain: Chain {

    private let next: Next

    public var proceed: Next {
        return { action in
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
        return { action in
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
