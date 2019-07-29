//
//  Combine+Sequence.swift
//  
//
//  Created by Jorge Revuelta on 25/07/2019.
//

import Foundation
import Combine

final public class PublisherSequence<Sequence: Swift.Sequence>: Publisher {
    
    public typealias Output = Sequence.Element
    
    public typealias Failure = Never
    
    
    fileprivate let _elements: Sequence
    
    init(elements: Sequence) {
        self._elements = elements
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Sequence.Element == S.Input {
        let subscription = PublisherSequenceSink(subscriber: subscriber, sequence: _elements)
        subscriber.receive(subscription: subscription)
    }
}

final private class PublisherSequenceSink<Sequence: Swift.Sequence, S: Subscriber>: Subscription where S.Input == Sequence.Element {
    
    private var subscriber: S?
    private let sequence: Sequence
    
    init(subscriber: S, sequence: Sequence) {
        self.subscriber = subscriber
        self.sequence = sequence
    }
    
    func request(_ demand: Subscribers.Demand) {
        var iterator = sequence.makeIterator()
        while let next = iterator.next() {
            _ = subscriber?.receive(next)
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

extension Publishers {
    
    public static func from<Sequence: Swift.Sequence>(_ sequence: Sequence) -> PublisherSequence<Sequence> {
        PublisherSequence(elements: sequence)
    }
    
    public static func of<Sequence: Swift.Sequence>(_ sequence: Sequence) -> PublisherSequence<Sequence> {
            PublisherSequence(elements: sequence)
        }
}
