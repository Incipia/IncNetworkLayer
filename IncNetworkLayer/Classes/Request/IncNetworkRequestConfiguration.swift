import Foundation

public final class IncNetworkRequestConfiguration {
   
   let baseURL: URL
   
   public init(baseURL: URL) {
      self.baseURL = baseURL
   }
   
   public static var shared: IncNetworkRequestConfiguration!
}
