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

public extension ObservableType where Element: StateType {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    func withStateChanges<T>(
        in stateComponent: KeyPath<Element, T>
    ) -> Observable<T> {
        return map(stateComponent)
    }

    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes using a `taskComponent` (i.e. a Task component in the State) to be completed (either successfully or failed).
     */
    func withStateChanges<T, Type, U: TypedTask<Type>>(
        in stateComponent: KeyPath<Element, T>,
        that taskComponent: KeyPath<Element, U>
    )
        -> Observable<T> {
        filter(taskComponent.appending(path: \.isCompleted))
            .map(stateComponent)
    }
}
