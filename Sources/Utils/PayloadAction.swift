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

    init(task: Task, payload: Payload?)
}

public protocol CompletableAction: Action & PayloadAction { }

public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never {
    init(task: Task)
}

public extension EmptyAction {
    init(task: Task, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}

public protocol KeyedPayloadAction {

    associatedtype Payload
    associatedtype Key: Hashable

    init(task: Task, payload: Payload?, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction { }

public protocol KeyedEmptyAction: Action & PayloadAction where Payload == Swift.Never {
    associatedtype Key: Hashable

    init(task: Task, key: Key)
}

public extension KeyedEmptyAction {
    init(task: Task, payload: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}
