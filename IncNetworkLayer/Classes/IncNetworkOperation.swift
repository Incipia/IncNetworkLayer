import Foundation

open class IncNetworkOperation: Operation {
   
   private var _isReady: Bool
   open override var isReady: Bool {
      get { return _isReady }
      set { update(
         { self._isReady = newValue }, key: "isReady") }
   }
   
   private var _isExecuting: Bool
   open override var isExecuting: Bool {
      get { return _isExecuting }
      set { update({ self._isExecuting = newValue }, key: "isExecuting") }
   }
   
   private var _isFinished: Bool
   open override var isFinished: Bool {
      get { return _isFinished }
      set { update({ self._isFinished = newValue }, key: "isFinished") }
   }
   
   private var _isCancelled: Bool
   open override var isCancelled: Bool {
      get { return _isCancelled }
      set { update({ self._isCancelled = newValue }, key: "isCancelled") }
   }
   
   private func update(_ change: (Void) -> Void, key: String) {
      willChangeValue(forKey: key)
      change()
      didChangeValue(forKey: key)
   }
   
   override init() {
      _isReady = true
      _isExecuting = false
      _isFinished = false
      _isCancelled = false
      super.init()
      name = "Network Operation"
   }
   
   open override var isAsynchronous: Bool {
      return true
   }
   
   open override func start() {
      if self.isExecuting == false {
         self.isReady = false
         self.isExecuting = true
         self.isFinished = false
         self.isCancelled = false
         print("\(self.name!) operation started.")
      }
   }
   
   /// Used only by subclasses. Externally you should use `cancel`.
   public func finish() {
      print("\(self.name!) operation finished.")
      self.isExecuting = false
      self.isFinished = true
   }
   
   open override func cancel() {
      print("\(self.name!) operation cancelled.")
      self.isExecuting = false
      self.isCancelled = true
   }
}
