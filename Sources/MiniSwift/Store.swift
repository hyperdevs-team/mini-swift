//
//  Store.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation
import Combine
import SwiftUI

final public class Store<S: State>: BindableObject {
    
    public var didChange = PassthroughSubject<S, Never>()
    
    public init(state: S,
                dispatcher: Dispatcher) {
        
    }
    
}
