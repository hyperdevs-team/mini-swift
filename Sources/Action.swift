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

public protocol Action {
    func isEqual(to other: Action) -> Bool
}

extension Action {
    /// String used as tag of the given Action based on his name.
    /// - Returns: The name of the action as a String.
    public var innerTag: String {
        return String(describing: type(of: self))
    }

    /**
     Static method to retrieve the name of the action as a tag.action.
     
     Calling this method in a static way return the Action name .Type cause it's not an instance.Action
     For this reason the String is split in two separated by a dot and returning the first part.
     */
    static var tag: String {
        let tag = String(describing: type(of: self))
        return tag.components(separatedBy: ".")[0]
    }
}
