//
//  IncNetworkDataMapper.swift
//  Pods
//
//  Created by Leif Meyer on 2/22/17.
//
//

import Foundation

public final class IncNetworkDataMapper<A: IncNetworkDataInitable>: IncNetworkMapper {
   
   public static func process(_ obj: Any?) throws -> A? {
      guard let obj = obj else { return nil }
      guard let data = obj as? Data else { throw IncNetworkMapperError.invalid }
      
      guard let item = A(with: data) else { throw IncNetworkMapperError.itemInitFailed }

      return item
   }
}
