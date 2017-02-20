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
   
   public func defaultJSONHeaders() -> [String: String] {
      return ["Content-Type": "application/json"]
   }
}
