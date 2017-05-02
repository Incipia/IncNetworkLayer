//
//  IncNetworkDataParameterRequest.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

import Foundation

public protocol IncNetworkDataParameterRequest: IncNetworkRequest {
   associatedtype Parameter: IncNetworkDataRepresentable
   var parameter: Parameter? { get }
}

extension IncNetworkDataParameterRequest {
   public var body: Data? {
      return parameter?.dataRepresentation
   }
}

open class IncNetworkDataRequestObject<Parameter: IncNetworkDataRepresentable>: IncNetworkDataParameterRequest {
   public var endpoint: String = ""

   public let parameter: Parameter? = nil
}
