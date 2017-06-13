import Foundation

public enum IncNetworkQueueNotification: String, IncNotificationType {
   case startedNetworkActivity, stoppedNetworkActivity
}

public class IncNetworkQueue: NSObject, IncNotifier {
   // MARK: - Types
   public enum Notification: String, IncNotificationType {
      case startedNetworkActivity, stoppedNetworkActivity
      
      public static var namePrefix: String { return "IncNetworkQueue" }
   }
   
   // MARK: - Singleton
   public static var shared: IncNetworkQueue!
   
   // MARK: - Public Properties
   let queue = OperationQueue()
   public var managesNetworkActivityIndicator: Bool = false
   
   // MARK: - Init
   public override init() {
      super.init()
      queue.addObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount), options: [.new, .old], context: nil)
   }
   
   // MARK: - Public
   public func addOperation(_ op: Operation) {
      queue.addOperation(op)
   }
   
   // MARK: - KVO
   public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard let count = change?[.newKey] as? Int else { fatalError() }
      guard let oldCount = change?[.oldKey] as? Int else { fatalError() }
      
      if oldCount == 0, count > 0 {
         post(notification: .startedNetworkActivity)
      } else if oldCount > 0, count == 0 {
         post(notification: .stoppedNetworkActivity)
      }
      
      guard managesNetworkActivityIndicator else { return }
      UIApplication.shared.isNetworkActivityIndicatorVisible = count > 0
   }
   
   // MARK: - Deinit
   deinit {
      queue.removeObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount))
   }
}
