import Foundation

final class IncNetworkArrayMapper<A: IncNetworkParsedItem> {
   
   static func process(_ obj: AnyObject?, mapper: ((Any?) throws -> A)) throws -> [A] {
      guard let json = obj as? [[String: AnyObject]] else { throw IncNetworkMapperError.invalid }
      
      var items = [A]()
      for jsonNode in json {
         let item = try mapper(jsonNode)
         items.append(item)
      }
      return items
   }
}
