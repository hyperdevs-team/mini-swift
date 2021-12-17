/*
 Copyright [2021] [Hyperdevs]
 
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

    init(task: AnyTask, payload: Payload?)
}

public protocol CompletableAction: Action & PayloadAction {}

public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never {
    init(task: AnyTask)
}

public extension EmptyAction {
    init(task _: AnyTask, payload _: Payload?) {
        fatalError("Never call this method from a EmptyAction")
    }
}

public protocol KeyedPayloadAction {
    associatedtype Payload
    associatedtype Key: Hashable

    init(task: AnyTask, payload: Payload?, key: Key)
}

public protocol KeyedCompletableAction: Action & KeyedPayloadAction {}
