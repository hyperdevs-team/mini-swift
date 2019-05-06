import Foundation

/**
 Store meta properties.
 
 - initOrder After construction invocation priority. Higher is lower.
 - logFn Optional function used to represent state in a human readable form.
 If null, current state string function will be used.
 */
public struct StoreProperties {
    public static let defaultPriority = 100

    public var order: Int
    public var logFn: (() -> String)?

    public init(withOrder order: Int = defaultPriority, withLogFn logFn: (() -> String)? = nil) {
        self.order = order
        self.logFn = logFn
    }
}
