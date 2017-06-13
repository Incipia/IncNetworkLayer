//
//  IncNotifier.swift
//  Pods
//
//  Created by Leif Meyer on 6/13/17.
//
//

import Foundation

public protocol IncNotificationBaseType {
   var name: Notification.Name { get }
   var userInfo: [AnyHashable : Any]? { get }
   
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]?)
}

public protocol IncNotificationType: IncNotificationBaseType, RawRepresentable {
   static var namePrefix: String { get }
}

public extension IncNotificationType where RawValue == String {
   static var namePrefix: String { return "" }
   var name: Notification.Name { return Notification.Name(rawValue: "\(Self.namePrefix).\(rawValue)") }
   var userInfo: [AnyHashable : Any]? { return nil }
   
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
   
   static func add(observer: Any, selector: Selector, notification: Notification, object: Any?)
   static func remove(observer: Any, notification: Notification, object: Any?)
}

public extension IncNotifier where Self: AnyObject {
   // MARK: - Instance Methods
   
   // Post
   func post(notification: Notification) {
      Self.post(notification: notification, object: self)
   }
   
   // MARK: - Static Functions
   
   // Post
   static func post(notification: Notification, object: Any? = nil) {
      NotificationCenter.default.post(name: notification.name, object: object, userInfo: notification.userInfo)
   }
   
   // Add
   static func add(observer: Any, selector: Selector, notification: Notification, object: Any? = nil) {
      NotificationCenter.default.addObserver(observer, selector: selector, name: notification.name, object: object)
   }
   
   // Remove
   static func remove(observer: Any, notification: Notification, object: Any? = nil) {
      NotificationCenter.default.removeObserver(observer, name: notification.name, object: object)
   }
}

public protocol IncNotifierObserver: class {
   var notifierBlocks: [Notification.Name : [((Notification?, AnyObject?) -> Bool)]] { get set }
   var receiveSelector: Selector { get }
   
   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U?) where U: AnyObject, U.Notification == T
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U?) where U: AnyObject, U.Notification == T
   func observe<T: IncNotificationBaseType>(notification: T)
}

public extension IncNotifierObserver where Self: NSObject {
   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U? = nil) where U: AnyObject, U.Notification == T {
      let name = notification.name
      var blocks = notifierBlocks[name] ?? []
      let matches = blocks.filter { return !$0(nil, object) }
      guard matches.isEmpty else { return }
      blocks.append({ [weak object] rawNotification, match in
         if let rawNotification = rawNotification,
            object == nil || (object as AnyObject) === (rawNotification.object as AnyObject),
            let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) {
            self.observe(notification: wrappedNotification)
            return true
         } else if let match = match, match.object == nil || match === object {
            if let object = object {
               U.remove(observer: self, notification: notification, object: object)
            } else {
               NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
            }
            return true
         } else {
            return false
         }
      })
      notifierBlocks[name] = blocks
      
      if let object = object {
         U.add(observer: self, selector: receiveSelector, notification: notification, object: object)
      } else {
         NotificationCenter.default.addObserver(self, selector: receiveSelector, name: notification.name, object: nil)
      }
   }
   
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U? = nil) where U: AnyObject, U.Notification == T {
      let name = notification.name
      guard let blocks = notifierBlocks[name] else { return }
      let filteredBlocks = blocks.filter { return !$0(nil, object) }
      notifierBlocks[name] = filteredBlocks.isEmpty ? nil : filteredBlocks
   }
   
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
