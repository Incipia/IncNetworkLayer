//
//  IncNetworkContextQueue.swift
//  Pods
//
//  Created by Leif Meyer on 7/7/17.
//
//

import Foundation

public protocol IncNetworkContextual {
   func enter(context: inout Any?)
   func leave(context: inout Any?)
}

public protocol IncNetworkTypedContextual: IncNetworkContextual {
   associatedtype Context
   
   func enterOwn(context: inout Context?)
   func leaveOwn(context: inout Context?)
}

public extension IncNetworkTypedContextual {
   func enter(context: inout Any?) {
      var ownContext = context as? Context
      enterOwn(context: &ownContext)
      context = ownContext
   }

   func leave(context: inout Any?) {
      var ownContext = context as? Context
      leaveOwn(context: &ownContext)
      context = ownContext
   }
}

open class IncNetworkContextQueue: IncNetworkQueue {
   // MARK: - Public Properties
   var context: Any?
   
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
