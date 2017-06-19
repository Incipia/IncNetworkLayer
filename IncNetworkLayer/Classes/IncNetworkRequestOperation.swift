import Foundation

public enum IncNetworkRequestOperationResult<SuccessType, ErrorType> {
   case success(SuccessType)
   case nullSuccess
   case error(ErrorType, Error)
   case failure(Error)
}

open class IncNetworkRequestOperation<SuccessMapper: IncNetworkMapper, ErrorMapper: IncNetworkMapper>: IncNetworkOperation {
   // MARK: - Private Properties
   private let _service: IncNetworkRequestService
   private let _request: IncNetworkRequest
   
   // MARK: - Public Properties
   public var completion: ((IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>) -> Void)?
   public var completionQueue: DispatchQueue?

   // MARK: - Init
   public init(request: IncNetworkRequest) {
      self._service = IncNetworkRequestService(IncNetworkRequestConfiguration.shared)
      self._request = request
      super.init()
   }

   // MARK: - Public
   open override func cancel() {
      _service.cancel()
      super.cancel()
   }
   
   open override func execute() {
      _service.request(_request, success: _handleSuccess, failure: _handleFailure)
   }

   // MARK: - Private
   private func _handleSuccess(_ response: Any?) {
      do {
         if let item = try SuccessMapper.process(response) {
            _handleCompletion(.success(item))
         } else {
            _handleCompletion(.nullSuccess)
         }
      } catch {
         _handleCompletion(.failure(error))
      }
   }
   
   private func _handleFailure(_ error: Error, data: Data?) {
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
            _handleCompletion(.error(item, error))
         } else {
            _handleCompletion(.failure(error))
         }
      } catch {
         _handleCompletion(.failure(error))
      }
   }
   
   private func _handleCompletion(_ result: IncNetworkRequestOperationResult<SuccessMapper.Item, ErrorMapper.Item>, shouldFinish: Bool = true) {
      if let queue = completionQueue, let completion = completion {
         queue.async {
            completion(result)
            if shouldFinish {
               self.finish()
            }
         }
      } else {
         completion?(result)
         if shouldFinish {
            finish()
         }
      }
   }
}
