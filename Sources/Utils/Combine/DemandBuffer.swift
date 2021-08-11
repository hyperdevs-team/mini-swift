import Combine
import Foundation

public class DemandBuffer<S: Subscriber> {
    public struct Demand {
        var processed: Subscribers.Demand = .none
        var requested: Subscribers.Demand = .none
        var sent: Subscribers.Demand = .none
    }

    private let lock = NSRecursiveLock()
    private var buffer = [S.Input]()
    private let subscriber: S
    private var completion: Subscribers.Completion<S.Failure>?
    private var demandState = Demand()

    /// Initialize a new demand buffer for a provided downstream subscriber
    ///
    /// - parameter subscriber: The downstream subscriber demanding events
    public init(subscriber: S) {
        self.subscriber = subscriber
    }

    /// Buffer an upstream value to later be forwarded to
    /// the downstream subscriber, once it demands it
    ///
    /// - parameter value: Upstream value to buffer
    ///
    /// - returns: The demand fulfilled by the bufferr
    func buffer(value: S.Input) -> Subscribers.Demand {
        precondition(self.completion == nil,
                     "How could a completed publisher sent values?! Beats me 🤷‍♂️")

        switch demandState.requested {
        case .unlimited:
            return subscriber.receive(value)

        default:
            buffer.append(value)
            return flush()
        }
    }

    /// Complete the demand buffer with an upstream completion event
    ///
    /// This method will deplete the buffer immediately,
    /// based on the currently accumulated demand, and relay the
    /// completion event down as soon as demand is fulfilled
    ///
    /// - parameter completion: Completion event
    func complete(completion: Subscribers.Completion<S.Failure>) {
        precondition(self.completion == nil,
                     "Completion have already occured, which is quite awkward 🥺")

        self.completion = completion
        _ = flush()
    }

    /// Signal to the buffer that the downstream requested new demand
    ///
    /// - note: The buffer will attempt to flush as many events rqeuested
    ///         by the downstream at this point
    func demand(_ demand: Subscribers.Demand) -> Subscribers.Demand {
        flush(adding: demand)
    }

    /// Flush buffered events to the downstream based on the current
    /// state of the downstream's demand
    ///
    /// - parameter newDemand: The new demand to add. If `nil`, the flush isn't the
    ///                        result of an explicit demand change
    ///
    /// - note: After fulfilling the downstream's request, if completion
    ///         has already occured, the buffer will be cleared and the
    ///         completion event will be sent to the downstream subscriber
    private func flush(adding newDemand: Subscribers.Demand? = nil) -> Subscribers.Demand {
        lock.lock()
        defer { lock.unlock() }

        if let newDemand = newDemand {
            demandState.requested += newDemand
        }

        // If buffer isn't ready for flushing, return immediately
        guard demandState.requested > 0 || newDemand == Subscribers.Demand.none else { return .none }

        while !buffer.isEmpty && demandState.processed < demandState.requested {
            demandState.requested += subscriber.receive(buffer.remove(at: 0))
            demandState.processed += 1
        }

        if let completion = completion {
            // Completion event was already sent
            buffer = []
            demandState = .init()
            self.completion = nil
            subscriber.receive(completion: completion)
            return .none
        }

        let sentDemand = demandState.requested - demandState.sent
        demandState.sent += sentDemand
        return sentDemand
    }
}
