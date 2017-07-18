//
//  IncNetworkFormParameterRequest.swift
//  IncNetworkLayer
//
//  Created by Gregory Klein on 7/7/17.
//

import Foundation

public protocol IncNetworkFormParameterRequest: IncNetworkFormRequest {
   associatedtype Parameter: IncNetworkFormRepresentable
   var parameter: Parameter? { get }
}

extension IncNetworkFormParameterRequest {
   public var body: Data? {
      do {
         return try body(parameters: parameter?.formRepresentation)
      } catch {
         fatalError(error.localizedDescription)
      }
   }
}
