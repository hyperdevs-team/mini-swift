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
import RxSwift

/**
 The `Reducer` defines the behavior to be executed when a certain
 `Action` object is received.
 */
public class Reducer<A: Action>: Disposable {
    /// The `Action` type which the `Reducer` listens to.
    public let action: A.Type
    /// The `Dispatcher` object that sends the `Action` objects.
    public let dispatcher: Dispatcher
    /// The behavior to be executed when the `Dispatcher` sends a certain `Action`
    public let reducer: (A) -> Void

    private var disposable: Disposable!

    /**
     Initializes a new `Reducer` object.
     - Parameter action: The `Action` type that will be listened to.
     - Parameter dispatcher: The `Dispatcher` that sends the `Action`.
     - Parameter reducer: The closure that will be executed when the `Dispatcher`
     sends the defined `Action` type.
     */
    public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void) {
        self.action = action
        self.dispatcher = dispatcher
        self.reducer = reducer
        disposable = build()
    }

    private func build() -> Disposable {
        let disposable = dispatcher.subscribe(tag: action.tag) {
            self.reducer($0)
        }
        return disposable
    }

    /// Dispose resource.
    public func dispose() {
        disposable.dispose()
    }
}
