import Foundation
import RxSwift

public protocol Group: Disposable {
    var disposeBag: CompositeDisposable { get }
}

public class ReducerGroup: Group {
    public let disposeBag = CompositeDisposable()

    public init(_ builder: () -> [Disposable]) {
        let disposable = builder()
        disposable.forEach { _ = disposeBag.insert($0) }
    }

    public func dispose() {
        disposeBag.dispose()
    }
}
