import Foundation

public typealias ServiceChain = (Action, Chain) -> Void

public protocol ServiceType {
    var id: UUID { get }
    var perform: ServiceChain { get }
}
