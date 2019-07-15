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
    func subscribe() -> Cancellable
}

public class ReducerGroup: Group {

    public let cancellableBag = CancellableBag()

    init(@ActionReducerBuilder builder: () -> Cancellable) {
        let cancellable = builder()
        cancellable.cancelled(by: cancellableBag)
    }

    public func subscribe() -> Cancellable {
        cancellableBag
    }

}
