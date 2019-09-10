/*
 Copyright [2019] [BQ]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/// Action for testing purposes.
public class TestOnlyAction: Action {
    public func isEqual(to other: Action) -> Bool {
        return true
    }
}

/// Interceptor class for testing purposes which mute all the received actions.
public class TestMiddleware: Middleware {

    public var id: UUID = UUID()

    private var interceptedActions: [Action] = []

    public var perform: MiddlewareChain {
        return { action, _ -> Action in
            self.interceptedActions.append(action)
            return TestOnlyAction()
        }
    }

    public init() { }

    /// Check if a given action have been intercepted before by the Middleware.
    ///
    /// - Parameter action: action to be checked
    /// - Returns: returns true if an action with the same params have been intercepted before.
    public func contains(action: Action) -> Bool {
        return interceptedActions.contains(where: {
            action.isEqual(to: $0)
        })
    }

    /// Check for actions of certain type being intercepted.
    ///
    /// - Parameter kind: Action type to be checked against the intercepted actions.
    /// - Returns: Array of actions of `kind` being intercepted.
    public func actions<T: Action>(of kind: T.Type) -> [T] {
        return interceptedActions.compactMap { $0 as? T }
    }

    /// Clear all the intercepted actions
    public func clear() {
        interceptedActions.removeAll()
    }
}
