import Foundation

public protocol IncNetworkRequest {
   var endpoint: String { get }
   var method: IncNetworkService.Method { get }
   var query: IncNetworkService.QueryType { get }
   var parameters: [String: Any]? { get }
   var headers: [String: String]? { get }
   var expectJSON: Bool { get }
}

extension IncNetworkRequest {
   
   public var endpoint: String { return "/" }
   public var method: IncNetworkService.Method { return .post }
   public var query: IncNetworkService.QueryType { return .json }
   public var parameters: [String: Any]? { return [:] }
   public var headers: [String : String]? { return defaultJSONHeaders() }
   public var expectJSON: Bool { return true }
   
   public func defaultJSONHeaders() -> [String: String] {
      return ["Content-Type": "application/json"]
   }
}
