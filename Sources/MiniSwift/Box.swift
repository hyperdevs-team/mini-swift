/*
 Copyright [2019] [BQ]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Dispatch

enum Sealant<R> {
    case idle
    case pending
    case resolved(R)
}

/// - Remark: not protocol ∵ http://www.russbishop.net/swift-associated-types-cont
class Box<T> {
    func inspect() -> Sealant<T> { fatalError() }
    func seal(_: T) {}
    func fill(_: Sealant<T>) { fatalError() }
}

final class SealedBox<T>: Box<T> {
    let value: T

    init(value: T) {
        self.value = value
        super.init()
    }

    override func inspect() -> Sealant<T> {
        return .resolved(value)
    }
}

class EmptyBox<T>: Box<T> {
    
    private var sealant: Sealant<T> = .pending
    
    override func fill(_ sealant: Sealant<T>) {
        switch sealant {
        case .idle, .pending:
            self.sealant = sealant
        default:
            return // don't seal the promise
        }
    }

    override func seal(_ value: T) {
        switch self.sealant {
        case .pending:
            self.sealant = .resolved(value)
        case .idle, .resolved:
            return // cannot be mutated!
        }
    }

    override func inspect() -> Sealant<T> {
        return self.sealant
    }
}
