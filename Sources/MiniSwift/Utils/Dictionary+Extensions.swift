//
//  Dictionary+Extensions.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation

public extension Dictionary {

    /// Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
    /// puts its result into the map under the given key and returns it.
    mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value {
        self[key, orPut: defaultValue()]
    }

    subscript (_ key: Key, orPut value: @autoclosure () -> Value) -> Value {
        mutating get {
            if let value = self[key] {
                return value
            }
            let value = value()
            self[key] = value
            return value
        }
    }
}
