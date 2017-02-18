import Foundation

public class IncNetworkService {
   
   private var _task: URLSessionDataTask?
   private var _successCodes: CountableClosedRange<Int> = 200...299
   private var _failureCodes: CountableClosedRange<Int> = 400...499
   
   public enum Result {
      case httpSuccess(code: Int)
      case httpFailure(code: Int)
      case unexpectedStatus(code: Int)
      case requestError(error: Error)
      case nonHTTP
   }
   
   public enum Method: String {
      case get, post, put, delete
   }
   
   public enum QueryType {
      case json, path
   }
   
   func makeRequest(for url: URL, method: Method, query type: QueryType,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    success: ((_ data: Data?, _ result: IncNetworkService.Result) -> Void)? = nil,
                    failure: ((_ data: Data?, _ result: IncNetworkService.Result) -> Void)? = nil) {
      
      
      var mutableRequest = _makeQuery(for: url, params: params, type: type)
      
      mutableRequest.allHTTPHeaderFields = headers
      mutableRequest.httpMethod = method.rawValue
      
      let session = URLSession.shared
      
      _task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { (data, response, error) in
         guard error == nil else {
            // Request failed, might be internet connection issue
            let error = error!
            failure?(data, .requestError(error: error))
            return
         }
         guard let httpResponse = response as? HTTPURLResponse else {
            success?(data, .nonHTTP)
            return
         }
         
         let statusCode = httpResponse.statusCode
         switch statusCode {
         case let statusCode where self._successCodes.contains(statusCode):
            print("Request finished with success code \(statusCode).")
            success?(data, .httpSuccess(code: statusCode))
         case let statusCode where self._failureCodes.contains(statusCode):
            print("Request finished with failure code \(statusCode).")
            failure?(data, .httpFailure(code: statusCode))
         default:
            print("Request finished with serious failure.")
            // Server returned response with status code different than
            // expected `successCodes`.
            failure?(data, .unexpectedStatus(code: statusCode))
         }
      })
      
      _task?.resume()
   }
   
   func cancel() {
      _task?.cancel()
   }
   
   private func _makeQuery(for url: URL, params: [String: Any]?, type: QueryType) -> URLRequest {
      switch type {
      case .json:
         var mutableRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                         timeoutInterval: 10.0)
         if let params = params {
            mutableRequest.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
         }
         
         return mutableRequest
      case .path:
         var query = ""
         
         params?.forEach { key, value in
            query = query + "\(key)=\(value)&"
         }
         
         var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
         components.query = query
         
         return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      }
      
   }
}


