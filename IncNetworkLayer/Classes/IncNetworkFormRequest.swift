//
//  IncNetworkFormRequest.swift
//  IncNetworkLayer
//
//  Created by Gregory Klein on 7/6/17.
//

import Foundation

public protocol IncNetworkFormRequest: IncNetworkRequest {}

extension IncNetworkFormRequest {
   public var method: IncNetworkService.Method { return .post }
   public var headers: [String : String]? { return defaultFormHeaders() }
   
   public func decode(response: Data?) throws -> Any? {
      guard let response = response, !response.isEmpty else { return nil }
      let form = try JSONSerialization.jsonObject(with: response, options: [])
      return form
   }
   
   public func body(with parameters: [String : Any]) -> Data? {
      guard !parameters.isEmpty else { return nil }
      let query = parameters.flatMap {
         guard let encodedValue = String(urlQueryValue: $0.value) else { return nil }
         return "\($0.key)=\(encodedValue)"
         }.joined(separator: "&")
      
      return query.data(using: .utf8)
   }
   
   public func defaultFormHeaders() -> [String: String] {
      return ["Content-Type": "application/x-www-form-urlencoded"]
   }
}

extension String {
   init?(urlQueryValue: Any) {
      guard let processedString = "\(urlQueryValue)"
         .replacingOccurrences(of: " ", with: "+")
         .replacingOccurrences(of: "=", with: "=".addingPercentEncoding(withAllowedCharacters: CharacterSet())!)
         .replacingOccurrences(of: "&", with: "&".addingPercentEncoding(withAllowedCharacters: CharacterSet())!)
         .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
      
      self.init(processedString)
   }
}
