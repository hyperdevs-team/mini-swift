import Foundation

public protocol StoreType: class {
    // swiftlint:disable:next type_name
    associatedtype S: State

    var state: S { get set }
    var initialState: S { get }
    func reloadState()
    func resetState()
    func initialize()
}
