import Foundation

open class IncNetworkArrayMapper<A: IncNetworkParsedItem> {
   
   static func process(_ obj: Any?, parse: ((_ json: Any) throws -> A?)) throws -> [A]? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [Any] else { throw IncNetworkMapperError.invalid }
      
      var items = [A]()
      for jsonNode in json {
         if let item = try parse(jsonNode) {
            items.append(item)
         }
      }
      return items
   }
}
