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

final class RouteResponseMapper: IncNetworkMapper<RouteItem>, IncNetworkParsedItem {
   
   static func process(_ obj: AnyObject?) throws -> RouteItem {
      return try process(obj, parse: { json in
         let route = json["route"] as? String
         let confidence = json["confidence"] as? Double
         if let route = route, let confidence = confidence {
            return RouteItem(route: route, confidence: confidence)
         }
         return nil
      })
   }
}

public class RouteOperation: IncNetworkRequestOperation {
   
   private let request: RouteRequest
   
   public var success: ((RouteItem) -> Void)?
   public var failure: ((Error) -> Void)?
   
   public init(start: String, end: String) {
      request = RouteRequest(start: start, end: end)
      super.init()
   }
   
   public override func start() {
      super.start()
      service.request(request, success: handleSuccess, failure: handleFailure)
   }
   
   private func handleSuccess(_ response: AnyObject?) {
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
