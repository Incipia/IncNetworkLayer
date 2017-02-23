import Foundation

public let DidPerformUnauthorizedOperation = "DidPerformUnauthorizedOperation"

public indirect enum IncNetworkRequestServiceError: Error {
   case request(error: Error, data: IncNetworkRequestServiceError)
   case httpResponse(code: Int, data: IncNetworkRequestServiceError)
   case noData
   case data(data: Data)
   case jsonData(json: Any)
   case nonJSONData(error: Error, data: Data)
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
      
      _service.makeRequest(for: url, method: request.method, query: request.query, params: request.parameters, headers: headers, success: { data, result in
         if let data = data, request.expectJSON {
            do {
               let json = try JSONSerialization.jsonObject(with: data as Data, options: [])
               success?(json)
            }
            catch {
               failure?(IncNetworkRequestServiceError.nonJSONData(error: error, data: data))
            }
         } else {
            success?(data)
         }
         
      }, failure: { data, result in
         let dataError: IncNetworkRequestServiceError = {
            guard let data = data else { return .noData }
            guard request.expectJSON else { return .data(data: data) }
            do {
               let json = try JSONSerialization.jsonObject(with: data as Data, options: [])
               return .jsonData(json: json)
            }
            catch {
               return .nonJSONData(error: error, data: data)
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
