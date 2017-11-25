import Foundation

public class IncNetworkService {
   
   private var _task: URLSessionDataTask?
   private var _successCodes: CountableClosedRange<Int> = 200...299
   private var _failureCodes: CountableClosedRange<Int> = 400...499
   private var _isCancelled = false
   
   public enum Result {
      case httpSuccess(code: Int)
      case httpFailure(code: Int)
      case unexpectedStatus(code: Int)
      case requestError(error: Error)
      case nonHTTP
   }
   
   public enum Method: String {
      case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
   }
   
   func makeRequest(for url: URL, method: Method,
                    body: Data? = nil,
                    query: String? = nil,
                    headers: [String: String]? = nil,
                    success: ((_ data: Data?, _ response: URLResponse?, _ result: IncNetworkService.Result) -> Void)? = nil,
                    failure: ((_ data: Data?, _ response: URLResponse?, _ result: IncNetworkService.Result) -> Void)? = nil) {
      
      
      var mutableRequest = _makeQuery(for: url, body: body, query: query)
      
      mutableRequest.allHTTPHeaderFields = headers
      mutableRequest.httpMethod = method.rawValue
      
      let session = URLSession.shared
      
      _task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { (data, response, error) in
         guard !self._isCancelled else { return }
         guard error == nil else {
            // Request failed, might be internet connection issue
            let error = error!
            failure?(data, response, .requestError(error: error))
            return
         }
         guard let httpResponse = response as? HTTPURLResponse else {
            success?(data, response, .nonHTTP)
            return
         }
         
         let statusCode = httpResponse.statusCode
         switch statusCode {
         case let statusCode where self._successCodes.contains(statusCode):
            print("Request finished with success code \(statusCode).")
            success?(data, response, .httpSuccess(code: statusCode))
         case let statusCode where self._failureCodes.contains(statusCode):
            print("Request finished with failure code \(statusCode).")
            failure?(data, response, .httpFailure(code: statusCode))
         default:
            print("Request finished with serious failure.")
            // Server returned response with status code different than
            // expected `successCodes`.
            failure?(data, response, .unexpectedStatus(code: statusCode))
         }
      })
      
      _task?.resume()
   }
   
   func cancel() {
      _isCancelled = true
      _task?.cancel()
   }
   
   private func _makeQuery(for url: URL, body: Data?, query: String?) -> URLRequest {
      var queryURL: URL;
      if let query = query {
         var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
         components.query = query
         queryURL = components.url!
      } else {
         queryURL = url
      }
      
      var request = URLRequest(url: queryURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
      
      if let body = body {
         request.httpBody = body
      }
      
      return request
   }
}


