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
   private var isObservingReadiness: Bool = false {
      didSet {
         guard isObservingReadiness != oldValue else { return }
         if isObservingReadiness {
            operations.forEach { $0.addObserver(self, forKeyPath: #keyPath(Operation.isReady), options: [], context: nil) }
         } else {
            operations.forEach { $0.removeObserver(self, forKeyPath: #keyPath(Operation.isReady)) }
         }
      }
   }
   
   // MARK: - Public Properties
   public var operations: [Operation] = []
   
   // MARK: - Overridden
   open override func addOperation(_ op: Operation) {
      if isObservingReadiness {
         op.addObserver(self, forKeyPath: #keyPath(Operation.isReady), options: [], context: nil)
      }
      operations.append(op)
      _attemptNextOperation()
   }
   
   // MARK: - KVO
   open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard let keyPath = keyPath else { return }
      
      switch keyPath {
      case #keyPath(OperationQueue.operationCount):
         super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
         fallthrough
      case #keyPath(Operation.isReady):
         _attemptNextOperation()
      default: break
      }
   }
   
   // MARK: - Private
   private func _attemptNextOperation() {
      guard queue.operationCount == 0 else { return }
      let maxPriority = operations.max { $0.queuePriority.rawValue > $1.queuePriority.rawValue }?.queuePriority ?? Operation.QueuePriority.veryLow
      if let nextOp = ((operations.filter { $0.isReady && $0.queuePriority == maxPriority }).sorted { $0.queuePriority.rawValue > $1.queuePriority.rawValue }).first {
         isObservingReadiness = false
         operations = operations.filter { $0 != nextOp }
         super.addOperation(nextOp)
      } else {
         isObservingReadiness = true
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
         contextualOperation.enter(context: &context)
      }
   }
   
   open override func operationCancelled(_ operation: IncNetworkOperation) {
      super.operationCancelled(operation)
      if let contextualOperation = operation as? IncNetworkContextual {
         contextualOperation.leave(context: &context)
      }
   }
   
   open override func operationFinished(_ operation: IncNetworkOperation) {
      super.operationFinished(operation)
      if let contextualOperation = operation as? IncNetworkContextual {
         contextualOperation.leave(context: &context)
      }
   }
}
