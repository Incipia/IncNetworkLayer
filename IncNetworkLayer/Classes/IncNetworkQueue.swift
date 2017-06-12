import Foundation

public class IncNetworkQueue: NSObject {
   
   public static var shared: IncNetworkQueue!
   
   let queue = OperationQueue()
   public var managesNetworkActivityIndicator: Bool = false
   
   public override init() {
      super.init()
      queue.addObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount), options: [.new], context: nil)
   }
   
   public func addOperation(_ op: Operation) {
      queue.addOperation(op)
   }
   
   // MARK: - KVO
   public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard managesNetworkActivityIndicator else { return }
      guard let count = change?[.newKey] as? Int else { fatalError() }
      
      UIApplication.shared.isNetworkActivityIndicatorVisible = count > 0
   }
}
