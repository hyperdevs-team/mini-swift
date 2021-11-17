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
import Combine

 
public protocol CancellableGroup: Cancellable {
    var disposeBag: [Cancellable] { get }
}

 
public class ReducerGroup: CancellableGroup {
    public var disposeBag: [Cancellable] = []

    public init(_ builder: Cancellable...) {
        let disposable = builder
        disposable.forEach { disposeBag.append($0) }
    }

    public func cancel() {
        disposeBag.forEach { $0.cancel() }
        disposeBag.removeAll()
    }
}
