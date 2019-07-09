//
//  TestMiddleware.swift
//  
//
//  Created by Jorge Revuelta on 02/07/2019.
//

import Foundation

/// Action for testing purposes.
public class TestOnlyAction: Action {
    public func isEqual(to other: Action) -> Bool {
        true
    }
}

/// Interceptor class for testing purposes which mute all the received actions.
public class TestMiddleware: Middleware {

    public var id: UUID = UUID()

    private var interceptedActions: [Action] = []

    public var perform: MiddlewareChain { { action, _ -> Action in
            self.interceptedActions.append(action)
            return TestOnlyAction()
        }
    }

    /// Check if a given action have been intercepted before for the TestInterceptor.
    ///
    /// - Parameter action: action to be checked
    /// - Returns: returns true if an action with the same params have been intercepted before.
    func contains(action: Action) -> Bool {
        interceptedActions.contains(where: {
            action.isEqual(to: $0)
        })
    }

    /// Check for actions of certain type being intercepted.
    ///
    /// - Parameter kind: Action type to be checked against the intercepted actions.
    /// - Returns: Array of actions of `kind` being intercepted.
    func actions<T: Action>(of kind: T.Type) -> [T] {
        return interceptedActions.compactMap { $0 as? T }
    }

    /// Clear all the intercepted actions
    func clear() {
        interceptedActions.removeAll()
    }
}
