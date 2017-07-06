import Foundation

public let DidPerformUnauthorizedOperation = "DidPerformUnauthorizedOperation"

public indirect enum IncNetworkRequestServiceError: Error {
   case request(error: Error, dataError: IncNetworkRequestServiceError)
   case httpResponse(code: Int, dataError: IncNetworkRequestServiceError)
   case invalidData(error: Error)
   case decodedData(decoded: Any?)
}

public class IncNetworkRequestService {
   
   private let _configuration: IncNetworkRequestConfiguration
   private let _service = IncNetworkService()
   
   init(_ conf: IncNetworkRequestConfiguration) {
      self._configuration = conf
   }
   
   public func request(_ request: IncNetworkRequest,
                success: ((Any?) -> Void)? = nil,
                failure: ((Error, Data?) -> Void)? = nil) {
      
      let url = _configuration.baseURL.appendingPathComponent(request.endpoint)
      let headers = request.headers
      // Set authentication token if available.
      //        headers?["X-Api-Auth-Token"] = BackendAuth.shared.token
      
      _service.makeRequest(for: url, method: request.method, body: request.body, query: request.query, headers: headers, success: { data, result in
         do {
            let response = try request.decode(response: data)
            success?(response)
         }
         catch {
            failure?(IncNetworkRequestServiceError.invalidData(error: error), data)
         }
         
      }, failure: { data, result in
         let dataError: IncNetworkRequestServiceError = {
            do {
               let decoded = try request.decode(response: data)
               return .decodedData(decoded: decoded)
            }
            catch {
               return .invalidData(error: error)
            }
         }()

         switch result {
         case .requestError(let error): failure?(IncNetworkRequestServiceError.request(error: error, dataError: dataError), data)
         case .httpFailure(let statusCode):
            if statusCode == 401 {
               // Operation not authorized
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: DidPerformUnauthorizedOperation), object: nil)
            }
            failure?(IncNetworkRequestServiceError.httpResponse(code: statusCode, dataError: dataError), data)
         case .unexpectedStatus(let statusCode): failure?(IncNetworkRequestServiceError.httpResponse(code: statusCode, dataError: dataError), data)
         default: failure?(dataError, data)
         }
      })
   }
   
   func cancel() {
      _service.cancel()
   }
}
