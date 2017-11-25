import Foundation

open class IncNetworkQueue: NSObject, IncNotifier {
   // MARK: - Types
   public enum Notification: IncNotificationType {
      case startedNetworkActivity, stoppedNetworkActivity, operationStarted(IncNetworkOperation!), operationFinished(IncNetworkOperation!), operationCancelled(IncNetworkOperation!)
      
      // MARK: - Public Properties
      static let operationKey = "operation"
      
      public var userInfo: [AnyHashable : Any]? {
         switch self {
         case .operationStarted(let op), .operationFinished(let op), .operationCancelled(let op): return op == nil ? nil : [Notification.operationKey : op]
         default: return nil
         }
      }
      
      // MARK: - Init
      public init?(name: Foundation.Notification.Name, userInfo: [AnyHashable : Any]?) {
         self.init(name: name)
         if let userInfo = userInfo, let operation = userInfo[Notification.operationKey] as? IncNetworkOperation {
            switch self {
            case .operationStarted: self = .operationStarted(operation)
            case .operationFinished: self = .operationFinished(operation)
            case .operationCancelled: self = .operationCancelled(operation)
            default: break
            }
         }
      }
      
      // MARK: - RawRepresentable
      public var rawValue: String {
         switch self {
         case .startedNetworkActivity: return "startedNetworkActivity"
         case .stoppedNetworkActivity: return "stoppedNetworkActivity"
         case .operationStarted: return "operationStarted"
         case .operationFinished: return "operationFinished"
         case .operationCancelled: return "operationCancelled"
         }
      }
      
      public init?(rawValue: String) {
         switch rawValue {
         case "startedNetworkActivity": self = .startedNetworkActivity
         case "stoppedNetworkActivity": self = .stoppedNetworkActivity
         case "operationStarted": self = .operationStarted(nil)
         case "operationFinished": self = .operationFinished(nil)
         case "operationCancelled": self = .operationCancelled(nil)
         default: return nil
         }
      }
   }
   
   // MARK: - Singleton
   public static var shared: IncNetworkQueue!
   
   // MARK: - Public Properties
   let queue: OperationQueue
   public var managesNetworkActivityIndicator: Bool = false
   public var notificationQueue: DispatchQueue?
   
   // MARK: - Subclass Hooks
   open func operationAdded(_ op: Operation) {}
   
   // MARK: - Init
   public init(queue: OperationQueue) {
      self.queue = queue
      super.init()
      _commonInit()
   }
   
   public override init() {
      queue = OperationQueue()
      super.init()
      _commonInit()
   }
   
   private func _commonInit() {
      queue.addObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount), options: [.new, .old], context: nil)
   }
   
   // MARK: - Public
   open func addOperation(_ op: Operation) {
      if let networkOp = op as? IncNetworkOperation {
         networkOp.delegate = self
      }
      queue.addOperation(op)
      operationAdded(op)
   }
   
   open func addOperations(_ ops: [Operation]) {
      ops.forEach { self.addOperation($0) }
   }
   
   // MARK: - KVO
   open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard let count = change?[.newKey] as? Int else { fatalError() }
      guard let oldCount = change?[.oldKey] as? Int else { fatalError() }
      
      if oldCount == 0, count > 0 {
         post(notification: .startedNetworkActivity)
      } else if oldCount > 0, count == 0 {
         post(notification: .stoppedNetworkActivity)
      }
      
      DispatchQueue.main.async {
         guard self.managesNetworkActivityIndicator else { return }
         UIApplication.shared.isNetworkActivityIndicatorVisible = count > 0
      }
   }
   
   // MARK: - Deinit
   deinit {
      queue.removeObserver(self, forKeyPath: #keyPath(OperationQueue.operationCount))
   }
}

extension IncNetworkQueue: IncNetworkOperationDelegate {
   open func operationStarted(_ operation: IncNetworkOperation) {
      post(notification: .operationStarted(operation))
   }
   
   open func operationCancelled(_ operation: IncNetworkOperation) {
      post(notification: .operationCancelled(operation))
      operation.delegate = nil
   }
   
   open func operationFinished(_ operation: IncNetworkOperation) {
      post(notification: .operationFinished(operation))
      operation.delegate = nil
   }
}
