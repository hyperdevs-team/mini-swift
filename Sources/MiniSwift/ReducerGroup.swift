//
//  ReducerGroup.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

public protocol Group {
    var cancellableBag: CancellableBag { get }
}

public struct ReducerGroup: Group {

    public let cancellableBag = CancellableBag()

    init(@ActionReducerBuilder builder: () -> [Cancellable]) {
        let cancellables = builder()
        cancellables.forEach {
            $0.cancelled(by: cancellableBag)
        }
    }
}

@_functionBuilder
public final class ActionReducerBuilder {

    public typealias Component = [Cancellable]

    public static func buildBlock(_ children: Component...) -> Component {
        children.flatMap { $0 }
    }
}
