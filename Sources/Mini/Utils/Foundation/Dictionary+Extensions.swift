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

extension Dictionary {
    /// Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
    /// puts its result into the map under the given key and returns it.
    public mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value {
        return self[key, orPut: defaultValue()]
    }

    public subscript(_ key: Key, orPut value: @autoclosure () -> Value) -> Value {
        mutating get {
            if let value = self[key] {
                return value
            }
            let value = value()
            self[key] = value
            return value
        }
    }

    public subscript(unwrapping key: Key) -> Value! {
        return self[key]
    }
}

extension Dictionary where Value: PromiseType, Key: Hashable {
    public subscript(promise key: Key) -> Value {
        return self[unwrapping: key]
    }

    public func hasValue(for key: Dictionary.Key) -> Bool {
        return keys.contains(key)
    }

    func notify<T: StoreType>(to store: T) -> Self {
        store.replayOnce()
        return self
    }

    @discardableResult
    public func resolve(with other: [Key: Value]) -> Self {
        return merging(other, uniquingKeysWith: { _, new in new })
    }

    public func mergingNew(with other: [Key: Value]) -> Self {
        return merging(other, uniquingKeysWith: { _, new in new })
    }
}

public extension Dictionary where Value: PromiseType, Key: Hashable, Value.Element: Equatable {
    static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        guard lhs.keys == rhs.keys else { return false }
        for (key1, key2) in zip(
            lhs.keys.sorted(by: { $0.hashValue < $1.hashValue }),
            rhs.keys.sorted(by: { $0.hashValue < $1.hashValue })
        ) {
            guard
                let left: Promise<Value.Element> = lhs[key1] as? Promise<Value.Element>,
                let right: Promise<Value.Element> = rhs[key2] as? Promise<Value.Element> else { return false }
            guard left == right else { return false }
        }
        return true
    }
}
