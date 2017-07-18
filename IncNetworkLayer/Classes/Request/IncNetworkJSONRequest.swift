//
//  IncNetworkJSONRequest.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

import Foundation

public protocol IncNetworkJSONRequest: IncNetworkRequest {}

extension IncNetworkJSONRequest {
   
   public var method: IncNetworkService.Method { return .post }
   public var headers: [String : String]? { return defaultJSONHeaders() }
   public func decode(data: Data?, response: URLResponse?) throws -> Any? {
      guard let data = data, !data.isEmpty else { return nil }
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      
      return json
   }
   
   public func body(with json: Any?) -> Data? {
      guard let json = json else { return nil }
      let body = try! JSONSerialization.data(withJSONObject: json, options: [])
      return body
   }
   
   public func defaultJSONHeaders() -> [String: String] {
      return ["Content-Type": "application/json"]
   }
}
