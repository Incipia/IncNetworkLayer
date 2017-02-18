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
      return item
   }
}

public class RouteOperation: IncNetworkRequestOperation {
   
   private let _request: RouteRequest
   
   public var success: ((RouteItem?) -> Void)?
   public var failure: ((Error) -> Void)?
   
   public init(start: String, end: String) {
      _request = RouteRequest(start: start, end: end)
      super.init()
   }
   
   public override func start() {
      super.start()
      service.request(_request, success: _handleSuccess, failure: _handleFailure)
   }
   
   private func _handleSuccess(_ response: Any?) {
      do {
         let item = try RouteResponseMapper.process(response)
         self.success?(item)
         self.finish()
      } catch {
         _handleFailure(error)
      }
   }
   
   private func _handleFailure(_ error: Error) {
      self.failure?(error)
      self.finish()
   }
}

final class RouteRequest: IncNetworkRequest {
   
   private let _start: String
   private let _end: String
   
   init(start: String, end: String) {
      self._start = start
      self._end = end
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
         "start": _start,
         "end": _end
      ]
   }
   
   var headers: [String : String]? {
      return defaultJSONHeaders()
   }
}
