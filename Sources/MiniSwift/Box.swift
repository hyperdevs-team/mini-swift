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
    case pending
    case resolved(R)
}

/// - Remark: not protocol ∵ http://www.russbishop.net/swift-associated-types-cont
class Box<T> {
    func inspect() -> Sealant<T> { fatalError() }
    func seal(_: T) {}
}

final class SealedBox<T>: Box<T> {
    let value: T
    
    init(value: T) {
        self.value = value
    }
    
    override func inspect() -> Sealant<T> {
        return .resolved(value)
    }
}

class EmptyBox<T>: Box<T> {
    private var sealant = Sealant<T>.pending
    
    override func seal(_ value: T) {
        guard case .pending = self.sealant else {
            return  // already fulfilled!
        }
        self.sealant = .resolved(value)
    }
    
    override func inspect() -> Sealant<T> {
        return self.sealant
    }
}
