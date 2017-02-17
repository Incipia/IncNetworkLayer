import Foundation

public class IncNetworkService {
   
   private var task: URLSessionDataTask?
   private var successCodes: CountableClosedRange<Int> = 200...299
   private var failureCodes: CountableClosedRange<Int> = 400...499
   private var nonHTTPCode: Int = -1
   
   public enum Method: String {
      case get, post, put, delete
   }
   
   public enum QueryType {
      case json, path
   }
   
   func makeRequest(for url: URL, method: Method, query type: QueryType,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    success: ((Data?) -> Void)? = nil,
                    failure: ((_ data: Data?, _ error: NSError?, _ responseCode: Int) -> Void)? = nil) {
      
      
      var mutableRequest = makeQuery(for: url, params: params, type: type)
      
      mutableRequest.allHTTPHeaderFields = headers
      mutableRequest.httpMethod = method.rawValue
      
      let session = URLSession.shared
      
      task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { (data, response, error) in
         let httpResponse = response as? HTTPURLResponse
         let statusCode = httpResponse?.statusCode ?? self.nonHTTPCode
         
         if let error = error {
            // Request failed, might be internet connection issue
            failure?(data, error as NSError, statusCode)
            return
         }
         
         switch statusCode {
         case let statusCode where self.successCodes.contains(statusCode):
            print("Request finished with success code \(statusCode).")
            success?(data)
         case let statusCode where self.failureCodes.contains(statusCode):
            print("Request finished with failure code \(statusCode).")
            failure?(data, error as NSError?, statusCode)
         case self.nonHTTPCode:
            print("Non-HTTP Request finished with success.")
            success?(data)
         default:
            print("Request finished with serious failure.")
            // Server returned response with status code different than
            // expected `successCodes`.
            let info = [
               NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
               NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoing mapping or backend bug."
            ]
            let error = NSError(domain: "IncNetworkService", code: 0, userInfo: info)
            failure?(data, error, statusCode)
         }
      })
      
      task?.resume()
   }
   
   func cancel() {
      task?.cancel()
   }
   
   
   //MARK: Private
   private func makeQuery(for url: URL, params: [String: Any]?, type: QueryType) -> URLRequest {
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


