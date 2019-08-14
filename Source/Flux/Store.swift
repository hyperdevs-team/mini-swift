import Foundation
import RxSwift

public class Store<S: StoreState, SC: Disposable>: StoreType {

    public typealias AssociatedState = S

    public var initialState: S
    public var dispatcher: Dispatcher
    public var storeController: SC
    public var properties: StoreProperties = StoreProperties()
    public var processor: BehaviorSubject<S>
    public var disposables: CompositeDisposable = CompositeDisposable()
    public var disposeBag: DisposeBag = DisposeBag()

    private var _state: S

    public required init(initialState: @autoclosure @escaping () -> S,
                         dispatcher: Dispatcher,
                         storeController: SC) {
        self.initialState = initialState()
        self.dispatcher = dispatcher
        self.storeController = storeController
        self.processor = BehaviorSubject<S>(value: self.initialState)
        self._state = self.initialState
    }

    public var state: S {
        get {
            return _state
        }
        set(value) {
            if !value.isEqualTo(_state) {
                _state = value
                processor.onNext(value)
            }
        }
    }

    public func subscribeActions() {
        fatalError("Abstract Method")
    }

    public func reloadState() {
        processor.onNext(state)
    }

    public func asObservable() -> Observable<S> {
        return processor.asObservable()
    }

    public func reset() {
        state = initialState
        storeController.dispose()
    }
}
