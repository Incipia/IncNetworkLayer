import Foundation

extension NSError {
   public class func incNetworkCannotParseResponse() -> NSError {
      let info = [NSLocalizedDescriptionKey: "Can't parse response. Please report a bug."]
      return NSError(domain: String(describing: self), code: 0, userInfo: info)
   }
}
