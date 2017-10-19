import Foundation

public class _IncNetworkObjectMapper<Mapper: IncNetworkMapper>: IncNetworkMapper {
   
   public class func process(_ obj: Any?) throws -> [String : Mapper.Item]? {
      guard let obj = obj else { return nil }
      guard let json = obj as? [String : Any] else { throw IncNetworkMapperError.invalid }
      
      var items: [String : Mapper.Item] = [:]
      for (key, jsonNode) in json {
         if let item = try Mapper.process(jsonNode) {
            items[key] = item
         }
      }
      return items
   }
}

public final class IncNetworkObjectMapper<Mapper: IncNetworkMapper>: _IncNetworkObjectMapper<Mapper> {
   // MARK: - IncNetworkMapper Protocol
   override public class func process(_ obj: Any?) throws -> [String : Mapper.Item]? {
      guard let item = try super.process(obj) else { throw IncNetworkMapperError.nullItem }
      
      return item
   }
}

public final class IncNetworkOptionalObjectMapper<Mapper: IncNetworkMapper>: _IncNetworkObjectMapper<Mapper> {}
