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
   static var namePrefix: String { return "\(type(of: self))" }
   var name: Notification.Name { return Notification.Name(rawValue: "\(Self.namePrefix).\(rawValue)") }
   var userInfo: [AnyHashable : Any]? { return nil }
   
   // MARK: - Init
   init?(name: Notification.Name, userInfo: [AnyHashable : Any]?) {
      self.init(name: name)
   }
   
   init?(name: Notification.Name) {
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
   
   // MARK: - Equatable
   static func == (lhs: Self, rhs: Self) -> Bool {
      return (lhs as AnyObject) === (rhs as AnyObject)
   }
}

public protocol IncNotifierBaseObserver: class {
   // MARK: - Public
   func startObserving<T: IncNotificationBaseType>(notification: T)
   func stopObserving<T: IncNotificationBaseType>(notification: T)
   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T
   func observe<T: IncNotificationBaseType>(notification: T)
}

public protocol IncNotifierObserver: IncNotifierBaseObserver {
   // MARK: - Public Properties
   var notifierObservers: [Notification.Name : [(object: AnyObject?, observer: NSObjectProtocol)]] { get set }
   var observationQueue: DispatchQueue? { get }
   
   // MARK: - Public
   func stopObserving()
}

public extension IncNotifierObserver {
   // MARK: - Public Properties
   var observationQueue: DispatchQueue? { return nil }
   
   // MARK: - Public
   func startObserving<T: IncNotificationBaseType>(notification: T) {
      let name = notification.name
      var observers = notifierObservers[name] ?? []
      let existingObservers = observers.filter { $0.object == nil }
      guard existingObservers.isEmpty else { return }
      let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] rawNotification in
         guard let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) else { return }
         guard let strongSelf = self else { return }
         if let queue = strongSelf.observationQueue {
            queue.async {
               strongSelf.observe(notification: wrappedNotification)
            }
         } else {
            strongSelf.observe(notification: wrappedNotification)
         }
      }
      observers.append((object: nil, observer: observer))
      notifierObservers[name] = observers
   }

   func startObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T {
      let name = notification.name
      var observers = notifierObservers[name] ?? []
      let existingObservers = observers.filter { $0.object === (object as AnyObject) }
      guard existingObservers.isEmpty else { return }
      let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: nil) { [weak self] rawNotification in
         guard (rawNotification.object as AnyObject) === (object as AnyObject) else { return }
         guard let wrappedNotification = T(name: rawNotification.name, userInfo: rawNotification.userInfo) else { return }
         if let queue = self?.observationQueue {
            queue.async {
               self?.observe(notification: wrappedNotification)
            }
         } else {
            self?.observe(notification: wrappedNotification)
         }
      }
      observers.append((object: object, observer: observer))
      notifierObservers[name] = observers
   }
   
   func stopObserving<T: IncNotificationBaseType>(notification: T) {
      let name = notification.name
      guard let observers = notifierObservers[name] else { return }
      observers.forEach {
         NotificationCenter.default.removeObserver($0.observer)
      }
      notifierObservers[name] = nil
   }
   
   func stopObserving<T: IncNotificationBaseType, U: IncNotifier>(notification: T, object: U) where U: AnyObject, U.Notification == T {
      let name = notification.name
      guard let observers = notifierObservers[name] else { return }
      let filteredObservers = observers.filter {
         guard $0.object === (object as AnyObject) else { return true }
         NotificationCenter.default.removeObserver($0.observer)
         return false
      }
      notifierObservers[name] = filteredObservers.isEmpty ? nil : filteredObservers
   }
   
   func stopObserving() {
      notifierObservers.forEach { $0.value.forEach { NotificationCenter.default.removeObserver($0.observer) } }
      notifierObservers = [:]
   }
}
