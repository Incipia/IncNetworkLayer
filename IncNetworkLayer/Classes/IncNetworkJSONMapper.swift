//
//  IncNetworkJSONMapper.swift
//  Pods
//
//  Created by Leif Meyer on 2/22/17.
//
//

import Foundation

public final class IncNetworkJSONMapper<A: IncNetworkJSONInitable>: IncNetworkMapper {
   
   public static func process(_ obj: Any?) throws -> A? {
      guard let obj = obj else { return nil }
      
      guard let item = try A(with: obj) else { throw IncNetworkMapperError.itemInitFailed }
      
      return item
   }
}
