//
//  Dispatch.swift
//  
//
//  Created by Jorge Revuelta on 29/07/2019.
//

import Foundation
import Combine
import SwiftUI

extension Task {
    public enum Lifetime {
        case once
        case forever(ignoringOld: Bool)
    }
}

//extension Publisher where Output: StoreType, Output: BindableObject {
//
//    public static func dispatch<A: Action, T: Task>(using dispatcher: Dispatcher,
//                                                    factory action: @autoclosure @escaping () -> A,
//                                                    taskMap: @escaping (Self.Output.State) -> T?,
//                                                    on store: Output,
//                                                    lifetime: Task.Lifetime = .once) -> AnyPublisher<Self.Output.State, Self.Failure> {
//        let publisher = Publishers.Create<Self.Output.State, Self.Failure> { subscriber -> AnyCancellable in
//            let action = action()
//            dispatcher.dispatch(action, mode: .sync)
//            let subscription = store.willChange.sink(receiveValue: {
//
//            })
//        }
//    }
//}
