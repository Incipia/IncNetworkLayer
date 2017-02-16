import Foundation

open class IncNetworkRequestOperation: IncNetworkOperation {
   
   public let service: IncNetworkRequestService
   
   public override init() {
      self.service = IncNetworkRequestService(IncNetworkRequestConfiguration.shared)
      super.init()
   }
   
   open override func cancel() {
      service.cancel()
      super.cancel()
   }
}
