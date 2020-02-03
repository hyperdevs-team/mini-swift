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

extension ObservableType {
    /// Take the first element that matches the filter function.
    ///
    /// - Parameter fn: Filter closure.
    /// - Returns: The first element that matches the filter.
    public func filterOne(_ condition: @escaping (Element) -> Bool) -> Observable<Element> {
        filter {
            condition($0)
        }.take(1)
    }

    public func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element> {
        filter { $0[keyPath: keyPath] }
    }

    public func map<T>(_ keyPath: KeyPath<Element, T>) -> Observable<T> {
        map { $0[keyPath: keyPath] }
    }

    public func one() -> Observable<Element> {
        take(1)
    }
}

extension ObservableType where Element: StateType {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    public func withStateChanges<T>(in stateComponent: @escaping @autoclosure () -> KeyPath<Element, T>, that componentProperty: @escaping @autoclosure () -> KeyPath<T, Bool>) -> Observable<T> {
        return map(stateComponent()).filter(componentProperty())
    }
}
