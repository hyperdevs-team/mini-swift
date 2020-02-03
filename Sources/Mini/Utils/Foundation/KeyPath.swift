//
//  File.swift
//
//
//  Created by Jorge Revuelta on 03/02/2020.
//

import Foundation

prefix operator ^

public prefix func ^ <Root, Value>(
    _ keypath: KeyPath<Root, Value>
) -> (Root) -> Value {
    return { root in root[keyPath: keypath] }
}
