//
//  AtomicState.swift
//  
//
//  Created by Jorge Revuelta on 11/07/2019.
//

import Foundation

@propertyWrapper
public struct AtomicState<V: StateType> {

    private let queue = DispatchQueue(label: "atomic state")
    private var _value: V

    public init(wrappedValue initialValue: V) {
        _value = initialValue
    }

    public var wrappedValue: V {
        set {
            queue.sync {
                if !newValue.isEqual(to: _value) {
                    _value = newValue
                }
            }
        }
        get { queue.sync { _value } }
    }
}
