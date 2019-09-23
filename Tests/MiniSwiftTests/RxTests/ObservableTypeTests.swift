//
//  ObservableTypeTests.swift
//  MiniSwiftTests
//
//  Created by Jorge Revuelta on 17/09/2019.
//

import XCTest
import RxTest
import RxBlocking
import RxSwift
@testable import MiniSwift


final class ObservableTypeTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    func test_filter_one() {
        let filterOneObserver = scheduler.createObserver(Int.self)
        
        scheduler.createColdObservable(
            [
                .next(10, 10),
                .next(20, 20),
                .next(30, 30),
                .completed(40)
            ]
        )
        .filterOne { $0 == 20 }
        .subscribe(filterOneObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(filterOneObserver.events, [
            .next(20, 20),
            .completed(20)
        ])
    }
    
    func test_dispatch_action_from_store() throws {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        
        store
            .reducerGroup
            .disposed(by: disposeBag)
        
        guard let state = try Observable<Store<TestState, TestStoreController>>
            .dispatch(using: dispatcher,
                      factory: SetCounterAction(counter: 1),
                      taskMap: { $0.counter },
                      on: store)
            .toBlocking(timeout: 5.0).first()
            else {
                fatalError()
        }
        
        XCTAssertTrue(state.counter.isResolved)
        XCTAssertTrue(state.counter.error == nil)
        XCTAssertEqual(state.counter.value, 1)
    }
}
