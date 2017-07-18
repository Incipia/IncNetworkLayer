//
//  IncNetworkDataMapper.swift
//  Pods
//
//  Created by Leif Meyer on 2/22/17.
//
//

import Foundation

internal class _IncNetworkDataMapper<Item: IncNetworkDataInitable>: IncNetworkMapper {
   
   public class func process(_ obj: Any?) throws -> Item? {
      guard let obj = obj else { return nil }
      guard let data = obj as? Data else { throw IncNetworkMapperError.invalid }
      
      guard let item = try Item(data: data) else { throw IncNetworkMapperError.itemInitFailed }

      return item
   }
}

public final class IncNetworkDataMapper<Item: IncNetworkDataInitable>: _IncNetworkDataMapper<Item> {
   // MARK: - IncNetworkMapper Protocol
   override public class func process(_ obj: Any?) throws -> Item? {
      guard let item = try super.process(obj) else { throw IncNetworkMapperError.nullItem }
      
      return item
   }
}

public final class IncNetworkOptionalDataMapper<Item: IncNetworkDataInitable>: _IncNetworkDataMapper<Item> {}
