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
    
    public var didChange: CurrentValueSubject<S, Never>
    
    private var _initialState: S
    private var _state: S
    private let dispatcher: Dispatcher
    
    private(set) public var state: S {
        set {
            if !newValue.isEqualTo(state) {
                _state = newValue
                didChange.send(newValue)
            }
        }
        get {
            _state
        }
    }
    
    public var initialState: S {
        _initialState
    }
    
    public init(state: S,
                dispatcher: Dispatcher) {
        self._initialState = state
        self._state = state
        self.dispatcher = dispatcher
        self.didChange = CurrentValueSubject(state)
    }
    
    public func replayOnce() {
        didChange.send(state)
    }
    
    public func reset() {
        state = initialState
    }
}
