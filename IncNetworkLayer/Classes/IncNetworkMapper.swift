import Foundation

protocol IncNetworkMapperProtocol {
   associatedtype Item
   static func process(_ obj: AnyObject?) throws -> Item
}

internal enum IncNetworkMapperError: Error {
   case invalid
   case missingAttribute
}

class IncNetworkMapper<A: IncNetworkParsedItem> {
   
   static func process(_ obj: AnyObject?, parse: (_ json: [String: AnyObject]) -> A?) throws -> A {
      guard let json = obj as? [String: AnyObject] else { throw IncNetworkMapperError.invalid }
      if let item = parse(json) {
         return item
      } else {
         throw IncNetworkMapperError.missingAttribute
      }
   }
}
