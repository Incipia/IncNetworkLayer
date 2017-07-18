import Foundation

public enum IncNetworkRequestError: Error {
   case invalidBody(encoding: String.Encoding)
   case invalidQueryParameter(name: String)
   case invalidBodyParameter(name: String)
}

public protocol IncNetworkRequest {
   var endpoint: String { get }
   var method: IncNetworkService.Method { get }
   var body: Data? { get }
   var query: String? { get }
   var headers: [String: String]? { get }
   func decode(data: Data?, response: URLResponse?) throws -> Any?
}

extension IncNetworkRequest {
   
   public var endpoint: String { return "/" }
   public var method: IncNetworkService.Method { return .get }
   public var query: String? { return nil }
   public var body: Data? { return nil }
   public var headers: [String : String]? { return nil }
   public func decode(data: Data?, response: URLResponse?) throws -> Any? {
      return data
   }

   public func query(with parameters: [String: Any]?) throws -> String? {
      guard let parameters = parameters, !parameters.isEmpty else { return nil }
      let query = try parameters.flatMap {
         if let valueArray = $0.value as? [Any] {
            let key = $0.key
            return try valueArray.map {
               guard let encodedValue = String(urlQueryValue: $0) else { throw IncNetworkRequestError.invalidQueryParameter(name: key) }
               return "\(key)=\(encodedValue)"
               }.joined(separator: "&")
         }
         guard let encodedValue = String(urlQueryValue: $0.value) else { throw IncNetworkRequestError.invalidQueryParameter(name: $0.key) }
         return "\($0.key)=\(encodedValue)"
         }.joined(separator: "&")
      
      return query
   }
}

extension String {
   // MARK: - Init
   init?(urlQueryValue: Any) {
      guard let processedString = "\(urlQueryValue)"
         .addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "=&+").inverted)?
         .replacingOccurrences(of: " ", with: "+")
         .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
      
      self.init(processedString)
   }
}
