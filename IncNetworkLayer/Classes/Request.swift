//
   //  Request.swift
   //  GigSalad
   //
   //  Created by Leif Meyer on 2/13/17.
   //  Copyright © 2017 Incipia. All rights reserved.
   //
   
import Foundation

public final class NetworkConfiguration {
   
   let baseURL: URL
   
   public init(baseURL: URL) {
      self.baseURL = baseURL
   }
   
   public static var shared: NetworkConfiguration!
}
