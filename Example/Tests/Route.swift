//
//  Route.swift
//  IncNetworkLayer
//
//  Created by Leif Meyer on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import IncNetworkLayer

struct RouteItem: IncNetworkParsedItem, IncNetworkJSONInitable {
   private enum Attribute: String {
      case route, confidence
   }
   
   public let route: String
   public let confidence: Double
   
   init?(with json: Any) throws {
      guard let json = json as? [String : Any] else { throw IncNetworkMapperError.invalid }
      guard let route = json[Attribute.route.rawValue] as? String else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.route.rawValue) }
      guard let confidence = json[Attribute.confidence.rawValue] as? Double else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.confidence.rawValue) }
      
      self.route = route
      self.confidence = confidence
   }
}

typealias RouteResponseMapper = IncNetworkJSONMapper<RouteItem>

final class RouteOperation: IncNetworkRequestOperation<RouteResponseMapper> {
   public init(start: String, end: String) {
      let request = RouteRequest(start: start, end: end)
      super.init(request: request)
   }
}

final class RouteRequest: IncNetworkRequest {
   
   private let _start: String
   private let _end: String
   
   init(start: String, end: String) {
      self._start = start
      self._end = end
   }
   
   var endpoint: String { return "/route-json" }
   
   var parameters: [String : Any]? {
      return [
         "start": _start,
         "end": _end
      ]
   }
   
}
