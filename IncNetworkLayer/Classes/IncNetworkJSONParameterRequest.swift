//
//  IncNetworkJSONParameterRequest.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

import Foundation

public protocol IncNetworkJSONParameterRequest: IncNetworkJSONRequest {
   associatedtype Parameter: IncNetworkJSONRepresentable
   var parameter: Parameter? { get }
}

extension IncNetworkJSONParameterRequest {
   public var body: Data? {
      return body(with: parameter?.jsonRepresentation)
   }
}

open class IncNetworkJSONRequestObject<Parameter: IncNetworkJSONRepresentable>: IncNetworkJSONParameterRequest {
   open var endpoint: String { return "/" }
   public let parameter: Parameter?
   
   public init(parameter: Parameter?) {
      self.parameter = parameter
   }
}
