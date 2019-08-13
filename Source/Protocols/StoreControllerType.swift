import Foundation
import RxSwift

public protocol StoreControllerType: class, Disposable {

    var disposeBag: DisposeBag { get set }
}

public extension StoreControllerType {
    func dispose() {
        self.disposeBag = DisposeBag()
    }
}
