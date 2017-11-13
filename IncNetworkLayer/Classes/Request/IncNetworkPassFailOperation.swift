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
   init?<OperationSuccessType, OperationErrorType>(operationResult: IncNetworkRequestOperationResult<OperationSuccessType, OperationErrorType>)
}

public enum IncNetworkPassFailError<SuccessType, ErrorType>: Error, IncNetworkPassFailErrorType {
   case unexpectedResultType(String), unexpectedResult(IncNetworkRequestOperationResult<SuccessType, ErrorType>)
   public init?<OperationSuccessType, OperationErrorType>(operationResult: IncNetworkRequestOperationResult<OperationSuccessType, OperationErrorType>) {
      switch operationResult {
      case .success: return nil
      default:
         if let operationResult = operationResult as? IncNetworkRequestOperationResult<SuccessType, ErrorType> {
            self = .unexpectedResult(operationResult)
         } else {
            self = .unexpectedResultType("\(type(of: operationResult))")
         }
      }
   }
}

public enum IncNetworkPassFailOperationResult<SuccessType, ErrorType: IncNetworkPassFailErrorType> {
   case success(SuccessType)
   case error(ErrorType)
}

open class IncNetworkBasePassFailOperation<ErrorType: IncNetworkPassFailErrorType, SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseRequestOperation<IncNetworkPassFailOperationResult<SuccessMapper.Item, ErrorType>, SuccessMapper, ErrorMapper> {
   // MARK: - Overridden
   open override func result(operationResult: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> IncNetworkPassFailOperationResult<SuccessMapper.Item, ErrorType> {
      if let error = ErrorType(operationResult: operationResult) { return .error(error) }
      switch operationResult {
      case .success(let item): return .success(item)
      default: fatalError("\(ErrorType.self) init must succeed for all operation results except .success")
      }
   }
}

open class IncNetworkPassFailOperation<SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBasePassFailOperation<IncNetworkPassFailError<SuccessMapper.Item, ErrorMapper.Item>, SuccessMapper, ErrorMapper> {}

public enum IncNetworkNullPassFailOperationResult<ErrorType: IncNetworkPassFailErrorType> {
   case success
   case error(ErrorType)
}

public enum IncNetworkOptinalPassFailError<SuccessType, ErrorType>: Error, IncNetworkPassFailErrorType {
   case unexpectedResultType(String), unexpectedResult(IncNetworkRequestOperationResult<SuccessType, ErrorType>)
   public init?<OperationSuccessType, OperationErrorType>(operationResult: IncNetworkRequestOperationResult<OperationSuccessType, OperationErrorType>) {
      switch operationResult {
      case .success, .nullSuccess: return nil
      default:
         if let operationResult = operationResult as? IncNetworkRequestOperationResult<SuccessType, ErrorType> {
            self = .unexpectedResult(operationResult)
         } else {
            self = .unexpectedResultType("\(type(of: operationResult))")
         }
      }
   }
}

open class IncNetworkBaseNullPassFailOperation<ErrorType: IncNetworkPassFailErrorType, SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseRequestOperation<IncNetworkNullPassFailOperationResult<ErrorType>, SuccessMapper, ErrorMapper> {
   // MARK: - Overridden
   open override func result(operationResult: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> IncNetworkNullPassFailOperationResult<ErrorType> {
      if let error = ErrorType(operationResult: operationResult) { return .error(error) }
      return .success
   }
}

open class IncNetworkNullPassFailOperation<SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseNullPassFailOperation<IncNetworkOptinalPassFailError<SuccessMapper.Item, ErrorMapper.Item>, SuccessMapper, ErrorMapper> {}

public enum IncNetworkOptionalPassFailOperationResult<SuccessType, ErrorType: IncNetworkPassFailErrorType> {
   case success(SuccessType?)
   case error(ErrorType)
}

open class IncNetworkBaseOptionalPassFailOperation<ErrorType: IncNetworkPassFailErrorType, SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseRequestOperation<IncNetworkOptionalPassFailOperationResult<SuccessMapper.Item, ErrorType>, SuccessMapper, ErrorMapper> {
   // MARK: - Overridden
   open override func result(operationResult: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> IncNetworkOptionalPassFailOperationResult<SuccessMapper.Item, ErrorType> {
      if let error = ErrorType(operationResult: operationResult) { return .error(error) }
      switch operationResult {
      case .success(let item): return .success(item)
      default: return .success(nil)
      }
   }
}

open class IncNetworkOptionalPassFailOperation<SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkBaseOptionalPassFailOperation<IncNetworkOptinalPassFailError<SuccessMapper.Item, ErrorMapper.Item>, SuccessMapper, ErrorMapper> {}
