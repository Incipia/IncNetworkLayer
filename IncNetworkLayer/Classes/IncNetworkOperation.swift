import Foundation

public protocol IncNetworkOperationDelegate: class {
   func operationStarted(_ operation: IncNetworkOperation)
   func operationCancelled(_ operation: IncNetworkOperation)
   func operationFinished(_ operation: IncNetworkOperation)
}

public extension IncNetworkOperationDelegate {
   func operationStarted(_ operation: IncNetworkOperation) {}
   func operationCancelled(_ operation: IncNetworkOperation) {}
   func operationFinished(_ operation: IncNetworkOperation) {}
}

open class IncNetworkOperation: Operation {
   // MARK: - Public Properties
   weak var delegate: IncNetworkOperationDelegate?
   
   #if DEBUG
   var showDebugOutput = true
   #endif

   // MARK: - Private Properties
   fileprivate var _isReady = true {
      willSet { willChangeValue(forKey: "isReady") }
      didSet { didChangeValue(forKey: "isReady") }
   }

   fileprivate var _isExecuting = false {
      willSet { willChangeValue(forKey: "isExecuting") }
      didSet { didChangeValue(forKey: "isExecuting") }
   }
   
   fileprivate var _isFinished = false {
      willSet { willChangeValue(forKey: "isFinished") }
      didSet { didChangeValue(forKey: "isFinished") }
   }
   
   fileprivate var _isCancelled = false {
      willSet { willChangeValue(forKey: "isCancelled") }
      didSet { didChangeValue(forKey: "isCancelled") }
   }
   
   // MARK: - Init
   override init() {
      super.init()
      
      name = "\(type(of: self))"
   }
   
   // MARK: - Overridden
   override open var isAsynchronous: Bool { return true }
   override open var isExecuting: Bool { return _isExecuting }
   override open var isFinished: Bool { return _isFinished }
   
   // MARK: - Public
   override open func start() {
      #if DEBUG
      if showDebugOutput {
         print("--- START : \(name) ---")
      }
      #endif
      _isExecuting = true
      execute()
      delegate?.operationStarted(self)
   }

   override open func cancel() {
      #if DEBUG
      if showDebugOutput {
         print("--- START : \(name) ---")
      }
      #endif
      _isExecuting = false
      _isCancelled = true
      delegate?.operationCancelled(self)
   }

   func finish() {
      #if DEBUG
      if showDebugOutput {
         print("--- FINISH : \(name) ---")
      }
      #endif
      _isExecuting = false
      _isFinished = true
      delegate?.operationFinished(self)
   }
   
   func execute() {
      fatalError("Must override!")
   }
}

