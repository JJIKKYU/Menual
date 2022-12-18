//
//  Log+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/12/18.
//

import UIKit
import FirebaseAnalytics

extension UIButton {
    private struct AssociatedKeys {
        static var actionName = "action"
    }
    
    var actionName: String? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.actionName) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.actionName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    convenience init(actionName: String) {
        self.init()
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var screenName = "screenName"
    }
    
    var screenName: String? {
        get {
            print("Log :: UIVIewController :: get!")
            return (objc_getAssociatedObject(self, &AssociatedKeys.screenName) as? String)
        }
        set(newValue) {
            guard let newValue = newValue as String? else { return }
            print("Log :: setValue = \(newValue)")
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.screenName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    convenience init(screenName: String) {
        self.init(nibName: nil, bundle: nil)

        self.screenName = screenName
    }
    
    convenience init(screenName2: String) {
        self.init()
    }
}

extension UIView {
    private struct AssociatedKeys {
        static var screenName = "screenName"
        static var categoryName = "categoryName"
    }
    
    var screenName: String? {
        get {
            print("Log :: UIView :: get!")
            return (objc_getAssociatedObject(self, &AssociatedKeys.screenName) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.screenName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var categoryName: String? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.categoryName) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.categoryName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    convenience init(screenName: String) {
        self.init()
    }
}

class MenualLog {
    class func logEventAction(responder: UIResponder, parameter: [String: Any]? = nil) {
        var responder: UIResponder? = responder
        var actioName: String = ""
        if let responder = responder as? UIButton {
            actioName = responder.actionName ?? ""
        }

        var screenName: String?
        var categoryName: String?
        
        while(screenName == nil) {
            if let responder = responder as? UIViewController {
                screenName = responder.screenName
            }
            
            if let responder = responder as? UIView {
                categoryName = responder.categoryName
            }
            responder = responder?.next
        }
        
        var logName: String = ""
        if screenName?.count ?? 0 > 0 {
            logName += screenName ?? ""
        }
        
        if categoryName?.count ?? 0 > 0 {
            logName += "_\(categoryName ?? "")"
        }
        
        // Analytics.logEvent(<#T##name: String##String#>, parameters: parameter)
    }
}
