//
//  Route.swift
//  IncNetworkLayer
//
//  Created by Leif Meyer on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import IncNetworkLayer

public struct RouteItem: IncNetworkParsedItem {
   
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

      if let item = item {
         return item
      } else {
         throw IncNetworkMapperError.invalid
      }
   }
}

public class RouteOperation: IncNetworkRequestOperation {
   
   private let request: RouteRequest
   
   public var success: ((RouteItem?) -> Void)?
   public var failure: ((Error) -> Void)?
   
   public init(start: String, end: String) {
      request = RouteRequest(start: start, end: end)
      super.init()
   }
   
   public override func start() {
      super.start()
      service.request(request, success: handleSuccess, failure: handleFailure)
   }
   
   private func handleSuccess(_ response: Any?) {
      do {
         let item = try RouteResponseMapper.process(response)
         self.success?(item)
         self.finish()
      } catch {
         handleFailure(error)
      }
   }
   
   private func handleFailure(_ error: Error) {
      self.failure?(error)
      self.finish()
   }
}

final class RouteRequest: IncNetworkRequest {
   
   private let start: String
   private let end: String
   
   init(start: String, end: String) {
      self.start = start
      self.end = end
   }
   
   var endpoint: String {
      return "/route-json"
   }
   
   var method: IncNetworkService.Method {
      return .post
   }
   
   var query: IncNetworkService.QueryType {
      return .json
   }
   
   var parameters: [String : Any]? {
      return [
         "start": start,
         "end": end
      ]
   }
   
   var headers: [String : String]? {
      return defaultJSONHeaders()
   }
}
