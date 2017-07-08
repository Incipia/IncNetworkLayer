import Foundation

internal class _IncNetworkArrayMapper<Mapper: IncNetworkMapper>: IncNetworkMapper {
   
   public class func process(_ obj: Any?) throws -> [Mapper.Item]? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [Any] else { throw IncNetworkMapperError.invalid }
      
      var items: [Mapper.Item] = []
      for jsonNode in json {
         if let item = try Mapper.process(jsonNode) {
            items.append(item)
         }
      }
      return items
   }
}

public final class IncNetworkArrayMapper<Mapper: IncNetworkMapper>: _IncNetworkArrayMapper<Mapper> {
   // MARK: - IncNetworkMapper Protocol
   override public class func process(_ obj: Any?) throws -> [Mapper.Item]? {
      guard let item = try super.process(obj) else { throw IncNetworkMapperError.nullItem }
      
      return item
   }
}

public final class IncNetworkOptionalArrayMapper<Mapper: IncNetworkMapper>: _IncNetworkArrayMapper<Mapper> {}
