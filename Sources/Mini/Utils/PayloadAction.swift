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

import Foundation

public protocol PayloadAction {
    associatedtype Payload

    init(promise: Promise<Payload>)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Void {
    init(promise: Promise<Void>)
}

public extension EmptyAction {
    init(promise: Promise<Payload>) {
        fatalError("Never call this method from a EmptyAction")
    }
}

public protocol KeyedPayloadAction {

    associatedtype Payload
    associatedtype Key: Hashable

    init(promise: [Key: Promise<Payload>])
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }
