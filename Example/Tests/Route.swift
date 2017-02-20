//
//  Route.swift
//  IncNetworkLayer
//
//  Created by Leif Meyer on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import IncNetworkLayer

struct RouteItem: IncNetworkParsedItem {
   
   public let route: String
   public let confidence: Double
}

final class RouteResponseMapper: IncNetworkObjectMapper<RouteItem>, IncNetworkMapper {
   private enum Attribute: String {
      case route, confidence
   }
   
   static func process(_ obj: Any?) throws -> RouteItem? {
      let item = try process(obj) { json in
         guard let route = json[Attribute.route.rawValue] as? String else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.route.rawValue) }
         guard let confidence = json[Attribute.confidence.rawValue] as? Double else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.confidence.rawValue) }
         let item = RouteItem(route: route, confidence: confidence)
         return item
      }
      return item
   }
}

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
   
   var method: IncNetworkService.Method { return .post }
   
   var query: IncNetworkService.QueryType { return .json }
   
   var parameters: [String : Any]? {
      return [
         "start": _start,
         "end": _end
      ]
   }
   
   var headers: [String : String]? { return defaultJSONHeaders() }
   
   var expectJSON: Bool { return true }
}
