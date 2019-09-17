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
        let filterOneObservable = scheduler.createObserver(Int.self)
        
        scheduler.createColdObservable(
            [
                .next(10, 10),
                .next(20, 20),
                .next(30, 30),
                .completed(40)
            ]
        )
        .filterOne { $0 == 20 }
        .subscribe(filterOneObservable)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(filterOneObservable.events, [
            .next(20, 20),
            .completed(20)
        ])
    }
}
