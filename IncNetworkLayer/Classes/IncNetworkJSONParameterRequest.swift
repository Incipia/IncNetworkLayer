//
//  IncNetworkJSONParameterRequest.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

import Foundation

public protocol IncNetworkJSONParameterRequest: IncNetworkJSONRequest {
   associatedtype P: IncNetworkJSONRepresentable
   var parameter: P? { get }
}

extension IncNetworkJSONParameterRequest {
   public var body: Data? {
      return body(with: parameter?.jsonRepresentation)
   }
}

open class IncNetworkJSONRequestObject<P: IncNetworkJSONRepresentable>: IncNetworkJSONParameterRequest {
   open var endpoint: String { return "/" }
   public let parameter: P?
   
   public init() {
      parameter = nil
   }
   
   public init(parameter: P) {
      self.parameter = parameter
   }
}
