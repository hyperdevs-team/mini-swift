/*
 Copyright [2021] [Hyperdevs]
 
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
#if canImport(Mini)
    import Mini

    /// Action for testing purposes.
    public class TestOnlyAction: Action {}

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

        public init() {}

    /// Check for actions of certain type being intercepted.
    ///
    /// - Parameter kind: Action type to be checked against the intercepted actions.
        /// - Returns: Array of actions of `kind` being intercepted.
        public func actions<T: Action>(of _: T.Type) -> [T] {
            return interceptedActions.compactMap { $0 as? T }
        }

        public func action<T: Action>(of _: T.Type, where params: (T) -> Bool) -> Bool {
            interceptedActions.compactMap { $0 as? T }.compactMap(params).first ?? false
        }

        /// Clear all the intercepted actions
        public func clear() {
            interceptedActions.removeAll()
        }
    }
#endif
