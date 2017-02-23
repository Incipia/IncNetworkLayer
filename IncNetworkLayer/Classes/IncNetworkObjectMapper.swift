import Foundation

final class IncNetworkObjectMapper<M: IncNetworkMapper>: IncNetworkMapper {
   
   public static func process(_ obj: Any?) throws -> [String : M.Item]? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [String : Any] else { throw IncNetworkMapperError.invalid }
      
      var items: [String : M.Item] = [:]
      for (key, jsonNode) in json {
         if let item = try M.process(jsonNode) {
            items[key] = item
         }
      }
      return items
   }
}
