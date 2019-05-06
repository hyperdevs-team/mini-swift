import Foundation
import RxSwift

/**
 Generic store that exposes its state as a [Flowable] and emits change events
 when [.setState] is called.

 - <S> The state type.
 */
public class Store<S: State>: StoreType, ObservableConvertibleType {

    // swiftlint:disable:next type_name
    public typealias E = S
    public typealias State = S

    private var _initialState: S
    private var _state: S
    private var processor: BehaviorSubject<S>
    let dispatcher: Dispatcher
    internal let disposables: CompositeDisposable = CompositeDisposable()
    internal let disposeBag: DisposeBag = DisposeBag()

    public var properties: StoreProperties = StoreProperties()

    public init(initialState: S, dispatcher: Dispatcher) {
        _initialState = initialState
        _state = initialState
        self.dispatcher = dispatcher
        self.processor = BehaviorSubject<S>(value: initialState)
    }

    public var state: S {
        get {
            return _state
        }
        set(value) {
            if !value.isEqualTo(state) {
                _state = value
                processor.onNext(value)
            }
        }
    }

    public func reloadState() {
        processor.onNext(state)
    }

    public func resetState() {
        state = initialState
    }

    public func initialize() {
        fatalError("Abstract Method")
    }

    public var initialState: S {
        return _initialState
    }

    public func asObservable() -> Observable<S> {
        return processor.asObservable()
    }
}
