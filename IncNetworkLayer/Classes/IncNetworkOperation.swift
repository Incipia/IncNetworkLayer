import Foundation

open class IncNetworkOperation: Operation {
   #if DEBUG
   // MARK: - Public Properties
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
   
   // MARK: - Overridden
   override open var isAsynchronous: Bool { return true }
   override open var isExecuting: Bool { return _isExecuting }
   override open var isFinished: Bool { return _isFinished }
   
   // MARK: - Public
   override open func start() {
      #if DEBUG
      if showDebugOutput {
         print("--- START : \(type(of: self)) ---")
      }
      #endif
      _isExecuting = true
      execute()
   }

   override open func cancel() {
      #if DEBUG
      if showDebugOutput {
         print("--- START : \(type(of: self)) ---")
      }
      #endif
      _isExecuting = false
      _isCancelled = true
   }

   func finish() {
      #if DEBUG
      if showDebugOutput {
         print("--- FINISH : \(type(of: self)) ---")
      }
      #endif
      _isExecuting = false
      _isFinished = true
   }
   
   func execute() {
      fatalError("Must override!")
   }
}

