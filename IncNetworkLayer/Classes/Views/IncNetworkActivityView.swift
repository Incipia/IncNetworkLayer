//
//  ActivityView.swift
//  GigSalad
//
//  Created by Leif Meyer on 6/19/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public final class IncNetworkActivityView: UIView, IncNotifierObserver {
   // MARK: - Private Properties
   private static var _window: UIWindow = {
      let window = UIWindow(frame: UIScreen.main.bounds)
      window.windowLevel = (UIApplication.shared.delegate?.window??.windowLevel ?? 0) - 1
      window.isHidden = true
      window.isUserInteractionEnabled = false
      let vc = UIViewController()
      window.rootViewController = vc
      shared.frame = CGRect(x: 0, y: window.bounds.size.height - 24.0, width: window.bounds.size.width, height: 24.0)
      vc.view.addSubview(shared)
      return window
   }()
   
   fileprivate var _hideTimer: Timer?
   
   // MARK: Public Properties
   public class var isShowing: Bool {
      get { return !_window.isHidden }
      set {
         guard _window.isHidden == newValue else { return }
         _window.isHidden = !newValue
         if newValue {
            shared.startObserving()
            if !hidesAutomatically {
               _show()
            }
         } else {
            shared.stopObserving()
            shared.clear()
            _hide()
         }
      }
   }
   public static var hidesAutomatically: Bool = false {
      didSet {
         guard hidesAutomatically != oldValue else { return }
         if hidesAutomatically, isShowing, shared.label.alpha == 0 {
            _hide()
         }
      }
   }
   
   public static var shared: IncNetworkActivityView = {
      return IncNetworkActivityView()
   }()
   
   public var label: UILabel
   
   // MARK: - Init
   public override init(frame: CGRect) {
      label = UILabel()
      label.adjustsFontSizeToFitWidth = true
      label.minimumScaleFactor = 0.5
      label.lineBreakMode = .byTruncatingHead
      label.numberOfLines = 1
      label.translatesAutoresizingMaskIntoConstraints = false
      label.alpha = 0
      super.init(frame: frame)
      
      addSubview(label)
      NSLayoutConstraint.activate([
         label.heightAnchor.constraint(equalTo: heightAnchor),
         label.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
         label.centerXAnchor.constraint(equalTo: centerXAnchor),
         label.centerYAnchor.constraint(equalTo: centerYAnchor),
         ])
   }
   
   public required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   // MARK: - Public
   public func startObserving() {
      startObserving(notification: IncNetworkQueue.Notification.operationStarted(nil), object: IncNetworkQueue.shared)
      startObserving(notification: IncNetworkQueue.Notification.operationCancelled(nil), object: IncNetworkQueue.shared)
      startObserving(notification: IncNetworkQueue.Notification.operationFinished(nil), object: IncNetworkQueue.shared)
   }
   
   public func clear() {
      label.alpha = 0
      if _hideTimer?.isValid ?? false {
         _hideTimer?.invalidate()
      }
      _hideTimer = nil
   }
   
   // MARK: - IncNotifierObserver
   public var notifierObservers: [Notification.Name : [(object: AnyObject?, observer: NSObjectProtocol)]] = [:]
   
   public var observationQueue: DispatchQueue? { return DispatchQueue.main }
   
   public func observe<T : IncNotificationBaseType>(notification: T) {
      guard let notification = notification as? IncNetworkQueue.Notification else { fatalError() }
      if _hideTimer == nil {
         UIView.animate(withDuration: 0.3) {
            self.label.alpha = 1.0
            if self == IncNetworkActivityView.shared, IncNetworkActivityView.hidesAutomatically {
               IncNetworkActivityView._show()
            }
         }
      } else if _hideTimer?.isValid ?? false {
         _hideTimer?.invalidate()
      }
      
      switch notification {
      case .operationStarted(let opertation):
         label.text = "\(opertation.name ?? "")..."
      case .operationCancelled(let opertation): label.text = "\(opertation.name ?? "")... Cancelled"
      case .operationFinished(let opertation): label.text = "\(opertation.name ?? "")... Finished"
      default: fatalError()
      }
      
      _hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
         UIView.animate(withDuration: 0.3) {
            self.label.alpha = 0
            if self == IncNetworkActivityView.shared, IncNetworkActivityView.hidesAutomatically {
               IncNetworkActivityView._hide()
            }
         }
         self._hideTimer = nil
      }
   }
   
   // MARK: - Private
   private static func _show() {
      UIApplication.shared.delegate?.window??.frame.size.height = UIScreen.main.bounds.height - 24.0
      UIApplication.shared.delegate?.window??.layoutIfNeeded()
   }
   
   private static func _hide() {
      UIApplication.shared.delegate?.window??.frame.size.height = UIScreen.main.bounds.height
      UIApplication.shared.delegate?.window??.layoutIfNeeded()
   }
}
