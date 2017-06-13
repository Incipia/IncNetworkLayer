//
//  IncNotifier.swift
//  Pods
//
//  Created by Leif Meyer on 6/13/17.
//
//

import Foundation

public protocol IncNotificationBaseType {
   // MARK: - Public Properties
   var name: Notification.Name { get }
   var userInfo: [AnyHashable : Any]? { get }
   
   // MARK: - Init
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]?)
}

public protocol IncNotificationType: IncNotificationBaseType, RawRepresentable {
   // MARK: - Public Properties
   static var namePrefix: String { get }
}

public extension IncNotificationType where RawValue == String {
   // MARK: - Public Properties
   static var namePrefix: String { return "" }
   var name: Notification.Name { return Notification.Name(rawValue: "\(Self.namePrefix).\(rawValue)") }
   var userInfo: [AnyHashable : Any]? { return nil }
   
   // MARK: - Init
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
      let rawName = name.rawValue
      let prefix = "\(Self.namePrefix)."
      guard let range = rawName.range(of: prefix), !range.isEmpty else { return nil }
      let rawValue = rawName.replacingCharacters(in: range, with: "")
      self.init(rawValue: rawValue)
   }
}

public protocol IncNotifier: Equatable {
   associatedtype Notification: IncNotificationType
   
   // MARK: - Public Properties
   var notificationQueue: DispatchQueue? { get }
   
   // MARK: - Public
   static func add(observer: Any, selector: Selector, notification: Notification, object: Any?)
   static func remove(observer: Any, notification: Notification, object: Any?)
}

public extension IncNotifier {
   // MARK: - Public Properties
   var notificationQueue: DispatchQueue? { return nil }
   
   // MARK: - Public
   func post(notification: Notification) {
      if let queue = notificationQueue {
         queue.async {
            Self.post(notification: notification, object: self)
         }
      } else {
         Self.post(notification: notification, object: self)
      }
   }
   
   static func post(notification: Notification, object: Any? = nil) {
      NotificationCenter.default.post(name: notification.name, object: object, userInfo: notification.userInfo)
   }

   static func add(observer: Any, selector: Selector, notification: Notification, object: Any? = nil) {
      NotificationCenter.default.addObserver(observer, selector: selector, name: notification.name, object: object)
   }
   
   static func remove(observer: Any, notification: Notification, object: Any? = nil) {
      NotificationCenter.default.removeObserver(observer, name: notification.name, object: object)
   }
}

public protocol IncNotifierObserver: class {
   // MARK: - Public
   func startObserving<T: IncNotificationBaseType>(notification: T)
   func stopObserving<T: IncNotificationBaseType>(notification: T)
   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T
   func observe<T: IncNotificationBaseType>(notification: T)
}

public protocol IncNotifierProxyObserver: IncNotifierObserver {
   // MARK: - Public Properties
   var notifierBlocks: [Notification.Name : [((Notification?, AnyObject?) -> Bool)]] { get set }
   var observerProxy: IncNotifierObserverProxy { get }

   // MARK: - Internal
   func _receive(notification: Notification)
}

public final class IncNotifierObserverProxy: NSObject {
   // MARK: - Private Properties
   private unowned let _observer: IncNotifierProxyObserver
   
   // MARK: - Init
   public init(observer: IncNotifierProxyObserver) {
      self._observer = observer
      
      super.init()
   }

   // MARK: - Public
   @objc func receive(notification: Notification) {
      _observer._receive(notification: notification)
   }
}

public extension IncNotifierProxyObserver {
   // MARK: - Public
   func startObserving<T: IncNotificationBaseType>(notification: T) {
      let name = notification.name
      var blocks = notifierBlocks[name] ?? []
      let observerProxy = self.observerProxy
      blocks.append({ [unowned self] rawNotification, match in
         if let rawNotification = rawNotification,
            let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) {
            self.observe(notification: wrappedNotification)
            return true
         } else if rawNotification == nil, match == nil {
            NotificationCenter.default.removeObserver(observerProxy, name: notification.name, object: nil)
            return true
         } else {
            return false
         }
      })
      notifierBlocks[name] = blocks
      
      let proxySelector = #selector(IncNotifierObserverProxy.receive(notification:))
      NotificationCenter.default.addObserver(observerProxy, selector: proxySelector, name: notification.name, object: nil)
   }

   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T {
      let name = notification.name
      var blocks = notifierBlocks[name] ?? []
      let observerProxy = self.observerProxy
      blocks.append({ [weak object, unowned self] rawNotification, match in
         if let rawNotification = rawNotification,
            object != nil && (object as AnyObject) === (rawNotification.object as AnyObject),
            let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) {
            self.observe(notification: wrappedNotification)
            return true
         } else if let match = match, match === object {
            U.remove(observer: observerProxy, notification: notification, object: match)
            return true
         } else if rawNotification == nil, match == nil {
            NotificationCenter.default.removeObserver(observerProxy, name: notification.name, object: nil)
            return true
         } else {
            return false
         }
      })
      notifierBlocks[name] = blocks
      
      let proxySelector = #selector(IncNotifierObserverProxy.receive(notification:))
      U.add(observer: observerProxy, selector: proxySelector, notification: notification, object: object)
   }
   
   func stopObserving<T: IncNotificationBaseType>(notification: T) {
      let name = notification.name
      guard let blocks = notifierBlocks[name] else { return }
      let filteredBlocks = blocks.filter { return !$0(nil, nil) }
      notifierBlocks[name] = filteredBlocks.isEmpty ? nil : filteredBlocks
   }
   
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T {
      let name = notification.name
      guard let blocks = notifierBlocks[name] else { return }
      let filteredBlocks = blocks.filter { return !$0(nil, object) }
      notifierBlocks[name] = filteredBlocks.isEmpty ? nil : filteredBlocks
   }
   
   // MARK: - Internal
   func _receive(notification: Notification) {
      let name = notification.name
      let observationCount = notifierBlocks[name]?.filter { return $0(notification, nil) }.count ?? 0
      _logObservationCount(observationCount, for: notification)
   }
   
   func _logObservationCount(_ count: Int, for notification: Notification) {
      #if DEBUG
         if count == 0 {
            print("NotifierObserver \(self) received notification \(notification) with no matching block.")
         }
      #endif
   }
}
