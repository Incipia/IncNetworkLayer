//
//  IncNetworkDataParameterRequest.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

import Foundation

public protocol IncNetworkDataParameterRequest: IncNetworkRequest {
   associatedtype P: IncNetworkDataRepresentable
   var parameter: P? { get }
}

extension IncNetworkDataParameterRequest {
   public var body: Data? {
      return parameter?.dataRepresentation
   }
}

open class IncNetworkDataRequestObject<P: IncNetworkDataRepresentable>: IncNetworkDataParameterRequest {
   public var endpoint: String = ""

   public let parameter: P? = nil
}
