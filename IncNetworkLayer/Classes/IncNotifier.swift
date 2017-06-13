//
//  IncNotifier.swift
//  Pods
//
//  Created by Leif Meyer on 6/13/17.
//
//

import Foundation

public protocol NotificationBaseType {
   var name: Notification.Name { get }
   var userInfo: [AnyHashable : Any]? { get }
   
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]?)
}

public protocol NotificationType: NotificationBaseType, RawRepresentable {
   static var namePrefix: String { get }
}

public extension NotificationType where RawValue == String {
   static var namePrefix: String { return "" }
   var name: Notification.Name { return Notification.Name(rawValue: "\(Self.namePrefix).\(rawValue)") }
   var userInfo: [AnyHashable : Any]? { return nil }
   
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
      self.init(rawValue: name.rawValue)
   }
}

public protocol Notifier: Equatable {
   associatedtype Notification: NotificationType
   
   static func add(observer: Any, selector: Selector, notification: Notification, object: Any?)
   static func remove(observer: Any, notification: Notification, object: Any?)
}

public extension Notifier where Self: AnyObject {
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

public protocol NotifierObserver: class {
   var notifierBlocks: [Notification.Name : [((Notification?, (selector: Selector, object: AnyObject?)?) -> Bool)]] { get set }
   var receiveSelector: Selector { get }
   
   func startObserving<T: NotificationBaseType, U: Notifier>(selector: Selector, notification: T, object: U?) where U: AnyObject, U.Notification == T
   func stopObserving<T: NotificationBaseType, U: Notifier>(selector: Selector, notification: T, object: U?) where U: AnyObject, U.Notification == T
   func observe(notification: Notification)
}

public extension NotifierObserver where Self: NSObject {
   func startObserving<T: NotificationBaseType, U: Notifier>(selector: Selector, notification: T, object: U?) where U: AnyObject, U.Notification == T {
      let name = notification.name
      var blocks = notifierBlocks[name] ?? []
      let matches = blocks.filter { return !$0(nil, (selector: selector, object: object)) }
      guard matches.isEmpty else { return }
      blocks.append({ rawNotification, match in
         if let rawNotification = rawNotification,
            object == nil || (object as AnyObject) === (rawNotification.object as AnyObject),
            let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) {
            self.perform(selector, with: wrappedNotification)
            return true
         } else if let match = match {
            return match.selector == selector && (match.object == nil || match.object === object)
         } else {
            return false
         }
      })
      notifierBlocks[name] = blocks
      
      if let object = object {
         U.add(observer: self, selector: receiveSelector, notification: notification, object: object)
      }
   }
   
   func stopObserving<T: NotificationBaseType, U: Notifier>(selector: Selector, notification: T, object: U?) where U: AnyObject, U.Notification == T {
      let name = notification.name
      guard let blocks = notifierBlocks[name] else { return }
      let filteredBlocks = blocks.filter { return !$0(nil, (selector: selector, object: object)) }
      notifierBlocks[name] = filteredBlocks.isEmpty ? nil : filteredBlocks
   }
   
   func receive(notification: Notification) {
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
