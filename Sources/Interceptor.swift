import Foundation

public typealias InterceptorChain = (Action, Chain) -> Void

public protocol Interceptor {
    var id: UUID { get }
    var perform: InterceptorChain { get }
    func stateWasReplayed(state: any State)
}
