import Foundation

/**
 Common interface for all actions.
 Tags must be names or custom tags related with the types that this action implements.
 */
public protocol Action {
	  func isEqualTo(_ other: Action) -> Bool
}

public extension Action {
    /// String used as tag of the given Action based on his name.
    /// - Returns: The name of the action as a String.
    var innerTag: String {
        return String(describing: type(of: self))
    }

    /**
     Static method to retrieve the name of the action as a tag.action.
     
     Calling this method in a static way return the Action name .Type cause it's not an instance.Action
     For this reason the String is split in two separated by a dot and returning the first part.
     */
    static var tag: String {
        let tag = String(describing: type(of: self))
        var splitTag = tag.components(separatedBy: ".")
        return splitTag[0]
    }
}
