//
//  Service.swift
//  
//
//  Created by Jorge Revuelta on 22/07/2019.
//

import Foundation

public typealias ServiceChain = (Action, Chain) -> Void

public protocol Service {
    var id: UUID { get }
    var perform: ServiceChain { get }
}

extension Mirror {
    static func reflectProperties<T>(
        of target: Any,
        matchingType type: T.Type = T.self,
        using closure: (T) -> Void
    ) {
        let mirror = Mirror(reflecting: target)

        for child in mirror.children {
            (child.value as? T).map(closure)
        }
    }
}
