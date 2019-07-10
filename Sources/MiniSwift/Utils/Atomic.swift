//
//  Atomic.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation

@propertyWrapper
public struct Atomic<A> {
    private var _value: A
    private let queue = DispatchQueue(label: "property wrapper")

    public init(initialValue: A) {
        _value = initialValue
    }

    public var wrappedValue: A {
        queue.sync { _value }
    }

    public mutating func mutate(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&_value)
        }
    }
}
