import Foundation

public let DidPerformUnauthorizedOperation = "DidPerformUnauthorizedOperation"

public indirect enum IncNetworkRequestServiceError: Error {
   case request(error: Error, data: IncNetworkRequestServiceError)
   case httpResponse(code: Int, data: IncNetworkRequestServiceError)
   case invalidData(error: Error, data: IncNetworkRequestServiceError)
   case decodedData(decoded: Any?, data: IncNetworkRequestServiceError)
   case noData
   case data(data: Data)
}

public class IncNetworkRequestService {
   
   private let _configuration: IncNetworkRequestConfiguration
   private let _service = IncNetworkService()
   
   init(_ conf: IncNetworkRequestConfiguration) {
      self._configuration = conf
   }
   
   public func request(_ request: IncNetworkRequest,
                success: ((Any?) -> Void)? = nil,
                failure: ((Error) -> Void)? = nil) {
      
      let url = _configuration.baseURL.appendingPathComponent(request.endpoint)
      
      var headers = request.headers
      // Set authentication token if available.
      //        headers?["X-Api-Auth-Token"] = BackendAuth.shared.token
      
      _service.makeRequest(for: url, method: request.method, body: request.body, query: request.query, headers: headers, success: { data, result in
         do {
            let response = try request.decode(response: data)
            success?(response)
         }
         catch {
            let dataError: IncNetworkRequestServiceError = data == nil ? .noData : .data(data: data!)
            failure?(IncNetworkRequestServiceError.invalidData(error: error, data: dataError))
         }
         
      }, failure: { data, result in
         let dataError: IncNetworkRequestServiceError = {
            let rawDataError: IncNetworkRequestServiceError = data == nil ? .noData : .data(data: data!)
            do {
               let decoded = try request.decode(response: data)
               return .decodedData(decoded: decoded, data: rawDataError)
            }
            catch {
               return .invalidData(error: error, data: rawDataError)
            }
         }()

         switch result {
         case .requestError(let error): failure?(IncNetworkRequestServiceError.request(error: error, data: dataError))
         case .httpFailure(let statusCode):
            if statusCode == 401 {
               // Operation not authorized
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: DidPerformUnauthorizedOperation), object: nil)
            }
            failure?(IncNetworkRequestServiceError.httpResponse(code: statusCode, data: dataError))
         case .unexpectedStatus(let statusCode): failure?(IncNetworkRequestServiceError.httpResponse(code: statusCode, data: dataError))
         default: failure?(dataError)
         }
      })
   }
   
   func cancel() {
      _service.cancel()
   }
}
