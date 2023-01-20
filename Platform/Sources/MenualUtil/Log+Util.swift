//
//  Log+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/12/18.
//

import UIKit
import FirebaseAnalytics

// MARK: - UIButton
extension UIButton {
    private struct AssociatedKeys {
        static var actionName = "action"
    }
    
    public var actionName: String? {
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
        self.actionName = actionName
    }
}

// MARK: - UIAction
extension UIAction {
    private struct AssociatedKeys {
        static var actionName = "action"
    }
    
    public var actionName: String? {
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
}

// MARK: - UITableViewCell
extension UITableViewCell {
    private struct AssociatedKeys {
        static var actionName = "action"
    }
    
    public var actionName: String? {
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
        self.actionName = actionName
    }
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell {
    private struct AssociatedKeys {
        static var actionName = "action"
    }
    
    public var actionName: String? {
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
}

// MARK: - UIViewController
extension UIViewController {
    private struct AssociatedKeys {
        static var screenName = "screenName"
    }
    
    public var screenName: String? {
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

// MARK: - UIView
extension UIView {
    private struct AssociatedKeys {
        static var categoryName = "categoryName"
    }

    public var categoryName: String? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.categoryName) as? String)
        }
        set(newValue) {
            guard let newValue = newValue as String? else { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.categoryName,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - MenualLog
public class MenualLog {
    public class func logEventAction(_ log: String, parameter: [String: Any]? = nil) {
        let isDebugMode: Bool = UserDefaults.standard.bool(forKey: "debug")
        if isDebugMode { return }

        print("Log :: 🍎 \(log), parameter = \(parameter)")
        Analytics.logEvent(log, parameters: parameter)
    }
    
    public class func logEventAction(responder: UIResponder, parameter: [String: Any]? = nil) {
        let isDebugMode: Bool = UserDefaults.standard.bool(forKey: "debug")
        if isDebugMode { return }

        var responder: UIResponder? = responder

        var actioName: String?
        if let responder = responder as? UIButton {
            actioName = responder.actionName ?? ""
        }
        else if let responder = responder as? UITableViewCell {
            actioName = responder.actionName ?? ""
        }
        
        else if let responder = responder as? UICollectionViewCell {
            actioName = responder.actionName ?? ""
        }
        
        
    

        var screenName: String = ""
        var categoryName: String = ""
        
        while(responder != nil) {
            print("Log :: responder = \(responder)")
            if let responder = responder as? UIViewController,
               let _screenName = responder.screenName,
               !_screenName.isEmpty
            {
                screenName =  _screenName + (screenName.isEmpty ? "" : "_") + screenName
            }
            
            if let responder = responder as? UIView,
               let _categoryName = responder.categoryName {
                categoryName = "_" + _categoryName + categoryName
            }
            responder = responder?.next
        }
        
        var logName: String = ""
        if !screenName.isEmpty {
            logName += screenName
        }
        
        if !categoryName.isEmpty {
            logName += "\(categoryName)"
        }
        
        if let actioName = actioName {
            logName += "_\(actioName)"
        }
        
        print("Log :: 🍎 \(logName), parameter = \(parameter)")
        
        Analytics.logEvent(logName, parameters: parameter)
    }
}
