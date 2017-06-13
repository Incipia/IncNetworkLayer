//
//  Route.swift
//  IncNetworkLayer
//
//  Created by Leif Meyer on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import IncNetworkLayer

struct RouteParameter: IncNetworkJSONRepresentable {
   let start: String
   let end: String
   
   var jsonRepresentation: Any? {
      return [
         "start": start,
         "end": end
      ]
   }
}

struct RouteItem: IncNetworkParsedItem, IncNetworkJSONInitable {
   private enum Attribute: String {
      case route, confidence
   }
   
   public let route: String
   public let confidence: Double
   
   init?(json: Any) throws {
      guard let json = json as? [String : Any] else { throw IncNetworkMapperError.invalid }
      guard let route = json[Attribute.route.rawValue] as? String else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.route.rawValue) }
      guard let confidence = json[Attribute.confidence.rawValue] as? Double else { throw IncNetworkMapperError.invalidAttribute(name: Attribute.confidence.rawValue) }
      
      self.route = route
      self.confidence = confidence
   }
}

typealias RouteResponseMapper = IncNetworkJSONMapper<RouteItem>

final class RouteOperation: IncNetworkRequestOperation<RouteResponseMapper, IncNetworkNilMapper> {
   public init(start: String, end: String) {
      let request = RouteRequest(start: start, end: end)
      super.init(request: request)
   }
}

final class RouteRequest: IncNetworkJSONRequest {
   
   private let _start: String
   private let _end: String
   
   init(start: String, end: String) {
      self._start = start
      self._end = end
   }
   
   var endpoint: String { return "/route-json" }
   
   var body: Data? {
      return body(with: [
         "start": _start,
         "end": _end
      ])
   }
   
}

final class RouteParameterOperation: IncNetworkRequestOperation<RouteResponseMapper, IncNetworkNilMapper> {
   public init(parameter: RouteParameter) {
      let request = RouteParameterRequest(parameter: parameter)
      super.init(request: request)
   }
}

struct RouteParameterRequest: IncNetworkJSONParameterRequest {
   var parameter: RouteParameter?
   var endpoint: String { return "/route-json" }
}

final class RouteObjectOperation: IncNetworkRequestOperation<RouteResponseMapper, IncNetworkNilMapper> {
   public init(parameter: RouteParameter) {
      let request = RouteObjectRequest(parameter: parameter)
      super.init(request: request)
   }
}

final class RouteObjectRequest: IncNetworkJSONRequestObject<RouteParameter> {
   override var endpoint: String { return "/route-json" }
}

final class RouteActivityObserver: NSObject, IncNotifierProxyObserver {
   var notifierBlocks: [Notification.Name : [((Notification?, AnyObject?) -> Bool)]] = [:]
   lazy var observerProxy: IncNotifierObserverProxy = {
      return IncNotifierObserverProxy(observer: self)
   }()
   
   var startedCount: Int = 0
   var stoppedCount: Int = 0
   
   override init() {
      super.init()
      startObserving(notification: IncNetworkQueue.Notification.startedNetworkActivity, object: IncNetworkQueue.shared)
   }
   
   func observe<T : IncNotificationBaseType>(notification: T) {
      guard let notification = notification as? IncNetworkQueue.Notification else { fatalError() }
      switch notification {
      case .startedNetworkActivity: startedCount += 1
      case .stoppedNetworkActivity: stoppedCount += 1
      }
   }
   
   deinit {
      stopObserving(notification: IncNetworkQueue.Notification.startedNetworkActivity, object: IncNetworkQueue.shared)
   }
}
