import Foundation

open class IncNetworkObjectMapper<A: IncNetworkParsedItem> {
   
   public static func process(_ obj: Any?, parse: (_ json: [String : Any]) throws -> A?) throws -> A? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [String : Any] else { throw IncNetworkMapperError.invalid }
      
      let item = try parse(json)
      
      return item
   }
}
