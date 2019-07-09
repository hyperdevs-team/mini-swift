//
//  Cancellable+Extensions.swift
//  
//
//  Created by Jorge Revuelta on 04/07/2019.
//

import Foundation
import Combine

class UnfairLock {

    private var lock = os_unfair_lock()

    func execute(closure: () -> Void) {
        os_unfair_lock_lock(&lock)
        closure()
        os_unfair_lock_unlock(&lock)
    }
}

public class CancellableBag: Cancellable {

    private var lock = UnfairLock()
    private var cancellables: [Cancellable] = []

    public init() { }

    deinit {
        cancel()
    }

    public func append(_ cancellable: Cancellable) {
        lock.execute {
            cancellables.append(cancellable)
        }
    }

    public func cancel() {
        lock.execute {
            cancellables.forEach { $0.cancel() }
            cancellables = []
        }
    }
}

public extension Cancellable {

    func cancelled(by bag: CancellableBag) {
        bag.append(self)
    }
}
