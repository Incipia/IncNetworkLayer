//
//  IncNetworkJSONMapper.swift
//  Pods
//
//  Created by Leif Meyer on 2/22/17.
//
//

import Foundation

fileprivate class _IncNetworkJSONMapper<Item: IncNetworkJSONInitable>: IncNetworkMapper {
   // MARK: - IncNetworkMapper Protocol
   public class func process(_ obj: Any?) throws -> Item? {
      guard let obj = obj else { return nil }
      
      guard let item = try Item(json: obj) else { throw IncNetworkMapperError.itemInitFailed }
      
      return item
   }
}

public final class IncNetworkJSONMapper<Item: IncNetworkJSONInitable>: _IncNetworkJSONMapper<Item> {
   // MARK: - IncNetworkMapper Protocol
   override public class func process(_ obj: Any?) throws -> Item? {
      guard let item = try super.process(obj) else { throw IncNetworkMapperError.nullItem }
      
      return item
   }
}

public final class IncNetworkOptionalJSONMapper<Item: IncNetworkJSONInitable>: _IncNetworkJSONMapper<Item> {}
