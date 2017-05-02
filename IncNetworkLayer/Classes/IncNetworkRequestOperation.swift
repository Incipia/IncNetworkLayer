import Foundation

public enum IncNetworkRequestOperationResult<SuccessType, ErrorType> {
   case success(SuccessType)
   case nullSuccess
   case error(ErrorType, Error)
   case failure(Error)
}

open class IncNetworkRequestOperation<SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkOperation {
   private let _service: IncNetworkRequestService
   private let _request: IncNetworkRequest
   
   public var completion: ((IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> Void)?

   public init(request: IncNetworkRequest) {
      self._service = IncNetworkRequestService(IncNetworkRequestConfiguration.shared)
      self._request = request
      super.init()
   }

   private func _handleSuccess(_ response: Any?) {
      do {
         if let item = try SuccessMapper.process(response) {
            self.completion?(.success(item))
         } else {
            self.completion?(.nullSuccess)
         }
         self.finish()
      } catch {
         self.completion?(.failure(error))
         self.finish()
      }
   }
   
   private func _handleFailure(_ error: Error, data: Data?) {
      defer { finish() }
      let response: Any? = {
         guard let error = error as? IncNetworkRequestServiceError else { return nil }
         switch error {
         case .request(_, let dataError), .httpResponse(_, let dataError):
            switch dataError {
            case .decodedData(let response): return response
            default: return nil
            }
         case .decodedData(let response): return response
         default: return nil
         }
      }()
      do {
         if let item = try ErrorMapper.process(response) {
            completion?(.error(item, error))
         } else {
            completion?(.failure(error))
         }
      } catch {
         completion?(.failure(error))
      }
   }

   open override func cancel() {
      _service.cancel()
      super.cancel()
   }
   
   open override func start() {
      super.start()
      _service.request(_request, success: _handleSuccess, failure: _handleFailure)
   }
}
