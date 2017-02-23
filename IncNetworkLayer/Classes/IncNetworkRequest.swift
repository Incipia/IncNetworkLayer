import Foundation

public protocol IncNetworkRequest {
   var endpoint: String { get }
   var method: IncNetworkService.Method { get }
   var body: Data? { get }
   var query: String? { get }
   var headers: [String: String]? { get }
   func decode(response: Data?) throws -> Any?
}

extension IncNetworkRequest {
   
   public var endpoint: String { return "/" }
   public var method: IncNetworkService.Method { return .post }
   public var query: String? { return nil }
   public var body: Data? { return nil }
   public var headers: [String : String]? { return defaultJSONHeaders() }
   public func decode(response: Data?) throws -> Any? {
      guard let response = response else { return nil }
      let json = try JSONSerialization.jsonObject(with: response, options: [])
      
      return json
   }
   
   public func query(with parameters: [String: Any]?) -> String? {
      guard let parameters = parameters, !parameters.isEmpty else { return nil }
      let query = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
      return query
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
