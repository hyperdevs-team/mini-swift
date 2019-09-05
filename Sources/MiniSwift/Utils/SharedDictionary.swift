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

/// Wrapper class to allow pass dictionaries with a memory reference
public class SharedDictionary<Key: Hashable, Value> {
    public var innerDictionary: [Key: Value]

    public init() {
        innerDictionary = [:]
    }

    public func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value {
        return self[key, orPut: defaultValue()]
    }

    public func get(withKey key: Key) -> Value? {
        return self[key]
    }

    public subscript (_ key: Key, orPut defaultValue: @autoclosure () -> Value) -> Value {
        return innerDictionary[key, orPut: defaultValue()]
    }

    public subscript (_ key: Key) -> Value? {
        return innerDictionary[key]
    }
}
