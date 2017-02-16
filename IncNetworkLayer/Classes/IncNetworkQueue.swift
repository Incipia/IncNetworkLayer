import Foundation

public class IncNetworkQueue {
    
    public static var shared: IncNetworkQueue!
    
    let queue = OperationQueue()
    
    public init() {}
    
    public func addOperation(_ op: Operation) {
        queue.addOperation(op)
    }
}
