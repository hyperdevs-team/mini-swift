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
        filter(^keyPath)
    }

    public func map<T>(_ keyPath: KeyPath<Element, T>) -> Observable<T> {
        map(^keyPath)
    }

    public func one() -> Observable<Element> {
        take(1)
    }

    public func skippingCurrent() -> Observable<Element> {
        skip(1)
    }

    /**
     Selects a property component from an `Element` filtering `nil` and emitting only distinct contiguous elements.
     */
    public func select<T: OptionalType>(_ keyPath: KeyPath<Element, T>) -> Observable<T.Wrapped> where T.Wrapped: Equatable {
        map(keyPath)
            .filterNil()
            .distinctUntilChanged()
    }
}

public extension ObservableType where Element: OptionalType {
    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.empty()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

extension ObservableType where Element: StateType {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    public func withStateChanges<T>(in stateComponent: KeyPath<Element, T>, that componentProperty: KeyPath<T, Bool>) -> Observable<T> {
        return map(stateComponent).filter(componentProperty)
    }
}
