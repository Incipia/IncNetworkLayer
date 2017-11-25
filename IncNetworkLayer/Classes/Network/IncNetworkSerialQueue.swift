//
//  IncNetworkSerialQueue.swift
//  Pods
//
//  Created by Leif Meyer on 7/7/17.
//
//

import Foundation

open class IncNetworkSerialQueue: IncNetworkQueue {
   // MARK: - Private Properties
   private var _isObservingReadiness: Bool = false {
      didSet {
         guard _isObservingReadiness != oldValue else { return }
         if _isObservingReadiness {
            operations.forEach { $0.addObserver(self, forKeyPath: #keyPath(Operation.isReady), options: [], context: nil) }
         } else {
            operations.forEach { $0.removeObserver(self, forKeyPath: #keyPath(Operation.isReady)) }
         }
      }
   }
   fileprivate let _dispatchQueueKey = DispatchSpecificKey<Void>()
   
   // MARK: - Public Properties
   public private(set) var operations: [Operation] = []
   public private(set) var currentOperation: Operation?
   public let dispatchQueue: DispatchQueue
   
   // MARK: - Init
   public init(queue: OperationQueue = OperationQueue(), dispatchQueue: DispatchQueue = .main) {
      self.dispatchQueue = dispatchQueue
      dispatchQueue.setSpecific(key: _dispatchQueueKey, value: ())
      super.init(queue: queue)
   }

   // MARK: - Subclass Hooks
   open func operationQueued(_ op: Operation) {}
   open func operationDequeued(_ op: Operation) {}
   open func queuedOperationCancelled( _ op: Operation) {}
   open func operationEnded(_ op: Operation) {}

   // MARK: - Life Cycle
   deinit {
      dispatchQueue.setSpecific(key: _dispatchQueueKey, value: nil)
   }
   
   // MARK: - Overridden
   open override func addOperation(_ op: Operation) {
      dispatchQueue.async {
         self.directAddOperation(op)
      }
   }
   
   open func removeOperation(_ op: Operation) {
      dispatchQueue.async {
         self.directRemoveOperation(op)
      }
   }

   // MARK: - KVO
   open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard let keyPath = keyPath else { return }
      
      switch keyPath {
      case #keyPath(OperationQueue.operationCount):
         super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
         fallthrough
      case #keyPath(Operation.isReady):
         dispatchQueue.async {
            self._attemptNextOperation()
         }
      case #keyPath(Operation.isCancelled):
         dispatchQueue.async {
            self._removeCancelledOperations()
         }
      default: break
      }
   }
   
   // MARK: - Direct Access
   public func directAddOperation(_ op: Operation) {
      _startObserving(op)
      operations.append(op)
      operationQueued(op)
      _removeCancelledOperations()
      _attemptNextOperation()
   }
   
   public func directRemoveOperation(_ op: Operation) {
      guard operations.contains(op) else { return }
      operations = operations.filter { $0 != op }
      _stopObserving(op)
      operationDequeued(op)
   }

   // MARK: - Private
   private func _startObserving(_ op: Operation) {
      op.addObserver(self, forKeyPath: #keyPath(Operation.isCancelled), options: [], context: nil)
      if _isObservingReadiness {
         op.addObserver(self, forKeyPath: #keyPath(Operation.isReady), options: [], context: nil)
      }
   }
   
   private func _stopObserving(_ op: Operation) {
      if _isObservingReadiness {
         op.removeObserver(self, forKeyPath: #keyPath(Operation.isReady))
      }
      op.removeObserver(self, forKeyPath: #keyPath(Operation.isCancelled))
   }
   
   private func _removeCancelledOperations() {
      let cancelledOps = operations.filter { $0.isCancelled }
      cancelledOps.forEach { cancelledOp in
         operations = operations.filter { $0 != cancelledOp }
         _stopObserving(cancelledOp)
         queuedOperationCancelled(cancelledOp)
      }
   }
   
   private func _attemptNextOperation() {
      guard queue.operationCount == 0 else { return }
      if let currentOp = currentOperation {
         currentOperation = nil
         operationEnded(currentOp)
      }
      let maxPriority = operations.max { $0.queuePriority.rawValue > $1.queuePriority.rawValue }?.queuePriority ?? Operation.QueuePriority.veryLow
      if let nextOp = ((operations.filter { $0.isReady && !$0.isCancelled && $0.queuePriority == maxPriority }).sorted { $0.queuePriority.rawValue > $1.queuePriority.rawValue }).first {
         _isObservingReadiness = false
         operations = operations.filter { $0 != nextOp }
         nextOp.removeObserver(self, forKeyPath: #keyPath(Operation.isCancelled))
         currentOperation = nextOp
         super.addOperation(nextOp)
      } else {
         _isObservingReadiness = true
      }
   }
}

open class IncNetworkSerialContextQueue<Context>: IncNetworkSerialQueue {
   // MARK: - Public Properties
   var context: Context?
   
   // MARK: - IncNetworkOperationDelegate
   open override func operationStarted(_ operation: IncNetworkOperation) {
      super.operationStarted(operation)
      if let contextualOperation = operation as? IncNetworkContextual {
         if (DispatchQueue.getSpecific(key: _dispatchQueueKey) != nil) {
            contextualOperation.enter(context: &context)
         } else {
            dispatchQueue.sync {
               contextualOperation.enter(context: &context)
            }
         }
      }
   }
   
   open override func operationCancelled(_ operation: IncNetworkOperation) {
      super.operationCancelled(operation)
      if let contextualOperation = operation as? IncNetworkContextual {
         if (DispatchQueue.getSpecific(key: _dispatchQueueKey) != nil) {
            contextualOperation.leave(context: &context)
         } else {
            dispatchQueue.sync {
               contextualOperation.leave(context: &context)
            }
         }
      }
   }
   
   open override func operationFinished(_ operation: IncNetworkOperation) {
      super.operationFinished(operation)
      if let contextualOperation = operation as? IncNetworkContextual {
         if (DispatchQueue.getSpecific(key: _dispatchQueueKey) != nil) {
            contextualOperation.leave(context: &context)
         } else {
            dispatchQueue.sync {
               contextualOperation.leave(context: &context)
            }
         }
      }
   }
}
