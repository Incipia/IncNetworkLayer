//
//  IncNetworkContextQueue.swift
//  Pods
//
//  Created by Leif Meyer on 7/7/17.
//
//

import Foundation

public protocol IncNetworkContextual {
   func enter<Context>(context: inout Context?)
   func leave<Context>(context: inout Context?)
}

public protocol IncNetworkTypedContextual: IncNetworkContextual {
   associatedtype OwnContext
   
   func enterOwn(context: inout OwnContext?)
   func leaveOwn(context: inout OwnContext?)
}

public extension IncNetworkTypedContextual {
   func enter<Context>(context: inout Context?) {
      var ownContext = context as? OwnContext
      enterOwn(context: &ownContext)
      context = ownContext as? Context
   }

   func leave<Context>(context: inout Context?) {
      var ownContext = context as? OwnContext
      leaveOwn(context: &ownContext)
      context = ownContext as? Context
   }
}

open class IncNetworkContextQueue<Context>: IncNetworkQueue {
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
