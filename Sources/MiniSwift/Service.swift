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
