//
//  DelayedImmutable.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation

@propertyWrapper
public struct DelayedImmutable<Value> {
    private var _value: Value?

    public init() { }

    public var value: Value {
        get {
            guard let value = _value else {
                fatalError("property accessed before being initialized")
            }
            return value
        }

        // Perform an initialization, trapping if the
        // value is already initialized.
        set {
            if _value != nil {
                fatalError("property initialized twice")
            }
            _value = newValue
        }
    }
}
