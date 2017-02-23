import Foundation

final class IncNetworkArrayMapper<M: IncNetworkMapper>: IncNetworkMapper {
   
   public static func process(_ obj: Any?) throws -> [M.Item]? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [Any] else { throw IncNetworkMapperError.invalid }
      
      var items: [M.Item] = []
      for jsonNode in json {
         if let item = try M.process(jsonNode) {
            items.append(item)
         }
      }
      return items
   }
}
