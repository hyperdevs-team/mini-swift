//
//  SharedDictionary.swift
//  
//
//  Created by Jorge Revuelta on 05/07/2019.
//

import Foundation

/// Wrapper class to allow pass dictionaries has a memory reference
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

    public subscript (_ key: Key, orPut defaultValue:  @autoclosure () -> Value) -> Value {
        return innerDictionary[key, orPut: defaultValue()]
    }

    public subscript (_ key: Key) -> Value? {
        return innerDictionary[key]
    }
}
