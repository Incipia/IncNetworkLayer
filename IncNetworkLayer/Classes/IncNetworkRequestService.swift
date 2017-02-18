import Foundation

public let DidPerformUnauthorizedOperation = "DidPerformUnauthorizedOperation"

public enum IncNetworkRequestServiceError: Error {
   case noData
   case nonJSONData
   case jsonData(json: Any)
}

public class IncNetworkRequestService {
   
   private let conf: IncNetworkRequestConfiguration
   private let service = IncNetworkService()
   
   init(_ conf: IncNetworkRequestConfiguration) {
      self.conf = conf
   }
   
   public func request(_ request: IncNetworkRequest,
                success: ((Any?) -> Void)? = nil,
                failure: ((Error) -> Void)? = nil) {
      
      let url = conf.baseURL.appendingPathComponent(request.endpoint)
      
      var headers = request.headers
      // Set authentication token if available.
      //        headers?["X-Api-Auth-Token"] = BackendAuth.shared.token
      
      service.makeRequest(for: url, method: request.method, query: request.query, params: request.parameters, headers: headers, success: { data, result in
         var json: Any? = nil
         if let data = data {
            json = try? JSONSerialization.jsonObject(with: data as Data, options: [])
         }
         success?(json)
         
      }, failure: { data, result in
         switch result {
         case .requestError(let error):
            failure?(error)
         case .httpFailure(let statusCode):
            if statusCode == 401 {
               // Operation not authorized
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: DidPerformUnauthorizedOperation), object: nil)
               return
            }
            fallthrough
         default:
            if let data = data {
               if let json = try? JSONSerialization.jsonObject(with: data as Data, options: []) as AnyObject {
                  let error = IncNetworkRequestServiceError.jsonData(json: json)
                  failure?(error)
               } else {
                  failure?(IncNetworkRequestServiceError.nonJSONData)
               }
            } else {
               failure?(IncNetworkRequestServiceError.noData)
            }
         }
      })
   }
   
   func cancel() {
      service.cancel()
   }
}
