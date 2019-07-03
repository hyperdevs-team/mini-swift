//
//  State.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation

public protocol State {
    func isEqual(to other: State) -> Bool
}

public extension State where Self: Equatable {
    func isEqual(to other: State) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

