//
//  IncNetworkNilMapper.swift
//  Pods
//
//  Created by Leif Meyer on 5/1/17.
//
//

import Foundation

public final class IncNetworkNilMapper: IncNetworkMapper {
   // MARK: - IncNetworkMapper Protocol
   public static func process(_ obj: Any?) throws -> Any? { return nil }
}
