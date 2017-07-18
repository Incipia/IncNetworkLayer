//
//  IncNetworkPassFailOperation.swift
//  Pods
//
//  Created by Leif Meyer on 7/18/17.
//
//

import Foundation

public protocol IncNetworkPassFailErrorType {
   // MARK: - Init
   init<SuccessType, OperationErrorType>(operationResult: IncNetworkRequestOperationResult<SuccessType, OperationErrorType>)
}

public enum IncNetworkPassFailOperationResult<SuccessType, ErrorType: IncNetworkPassFailErrorType> {
   case success(SuccessType)
   case error(ErrorType)
}

open class IncNetworkPassFailOperation<ErrorType: IncNetworkPassFailErrorType, SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseRequestOperation<IncNetworkPassFailOperationResult<SuccessMapper.Item, ErrorType>, SuccessMapper, ErrorMapper> {
   // MARK: - Overridden
   open override func result(operationResult: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> IncNetworkPassFailOperationResult<SuccessMapper.Item, ErrorType> {
      switch operationResult {
      case .success(let item): return .success(item)
      default: return .error(ErrorType(operationResult: operationResult))
      }
   }
}

public enum IncNetworkNullPassFailOperationResult<ErrorType: IncNetworkPassFailErrorType> {
   case success
   case error(ErrorType)
}

open class IncNetworkNullPassFailOperation<ErrorType: IncNetworkPassFailErrorType, SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseRequestOperation<IncNetworkNullPassFailOperationResult<ErrorType>, SuccessMapper, ErrorMapper> {
   // MARK: - Overridden
   open override func result(operationResult: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> IncNetworkNullPassFailOperationResult<ErrorType> {
      switch operationResult {
      case .success: return .success
      default: return .error(ErrorType(operationResult: operationResult))
      }
   }
}
