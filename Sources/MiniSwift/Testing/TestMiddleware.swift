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
        return true
    }
}

/// Interceptor class for testing purposes which mute all the received actions.
public class TestMiddleware {
    private var interceptedActions: [Action] = []

    /// Replace all actions with dummy ones
    func invoque(action: Action, chain: Chain) -> Action {
        interceptedActions.append(action)
        return TestOnlyAction()
    }

    /// Check if a given action have been intercepted before for the TestInterceptor.
    ///
    /// - Parameter action: action to be checked
    /// - Returns: returns true if an action with the same params have been intercepted before.
    func containsAction(action: Action) -> Bool {
        return interceptedActions.contains(where: { interceptedAction -> Bool in
            return action.isEqual(to: interceptedAction)
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
