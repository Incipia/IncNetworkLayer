import Foundation

public class IncNetworkRequestOperation: IncNetworkOperation {
   
   let service: IncNetworkRequestService
   
   public override init() {
      self.service = IncNetworkRequestService(IncNetworkRequestConfiguration.shared)
      super.init()
   }
   
   public override func cancel() {
      service.cancel()
      super.cancel()
   }
}
