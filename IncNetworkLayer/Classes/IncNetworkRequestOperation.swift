import Foundation

open class IncNetworkRequestOperation<R: IncNetworkRequest, M: IncNetworkMapper>: IncNetworkOperation {
   
   private let _service: IncNetworkRequestService
   private let _request: R
   
   public var success: ((M.Item?) -> Void)?
   public var failure: ((Error) -> Void)?

   public init(request: R) {
      self._service = IncNetworkRequestService(IncNetworkRequestConfiguration.shared)
      self._request = request
      super.init()
   }

   private func _handleSuccess(_ response: Any?) {
      do {
         let item = try M.process(response)
         self.success?(item)
         self.finish()
      } catch {
         _handleFailure(error)
      }
   }
   
   private func _handleFailure(_ error: Error) {
      self.failure?(error)
      self.finish()
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
