//
//  ReducerGroup.swift
//  
//
//  Created by Jorge Revuelta on 03/07/2019.
//

import Foundation
import Combine

/// Protocol that defines a type which you can subscribe to.
public protocol Subscribable {
    func subscribe() -> Cancellable
}

public protocol Group: Cancellable {
    var cancellableBag: CancellableBag { get }
}

public class ReducerGroup: Group {

    public let cancellableBag = CancellableBag()

    init(@ActionReducerBuilder builder: () -> Cancellable) {
        let cancellable = builder()
        cancellable.cancelled(by: cancellableBag)
    }

    public func cancel() {
        cancellableBag.cancel()
    }
}
