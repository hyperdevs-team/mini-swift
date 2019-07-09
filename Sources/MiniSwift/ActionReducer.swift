//
//  ActionReducer.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

// swiftlint:disable:next identifier_name
public func Reduce<T: Action>(dispatcher: Dispatcher, action: T.Type, reducer: @escaping (T) -> Void) -> [Cancellable] {
    [
        dispatcher.subscribe { (action: T) -> Void in
            reducer(action)
        }
    ]
}
