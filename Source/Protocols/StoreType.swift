import Foundation
import RxSwift

public protocol StoreType: class {
    associatedtype AssociatedState: StoreState

    var processor: BehaviorSubject<AssociatedState> { get set }
    var initialState: AssociatedState { get set }
    var state: AssociatedState { get set }
    func subscribeActions()
    func reloadState()
    func reset()
}
