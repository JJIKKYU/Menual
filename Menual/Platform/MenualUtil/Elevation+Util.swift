//
//  Elevation+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/03/16.
//

import Foundation
import UIKit

enum ShadowType {
    case shadow_0
    case shadow_1
    case shadow_2
    case shadow_3
    case shadow_4
    case shadow_5
    case shadow_6
}

extension UIView {
    func AppShadow(_ type: ShadowType) {
        var isDarkMode: Bool = false
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                isDarkMode = true
            }
        }
        
        if isDarkMode {
            layer.shadowOpacity = 0.48
        } else {
            layer.shadowOpacity = 0.16
        }
        
        layer.masksToBounds = false
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        
        switch type {
        case .shadow_0:
            layer.shadowOpacity = 0
        case .shadow_1:
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 8
        case .shadow_2:
            layer.shadowOffset = CGSize(width: 0, height: 8)
            layer.shadowRadius = 16
        case .shadow_3:
            layer.shadowOffset = CGSize(width: 0, height: 12)
            layer.shadowRadius = 24
        case .shadow_4:
            layer.shadowOffset = CGSize(width: 0, height: 16)
            layer.shadowRadius = 32
        case .shadow_5:
            layer.shadowOffset = CGSize(width: 0, height: 20)
            layer.shadowRadius = 40
        case .shadow_6:
            layer.shadowOffset = CGSize(width: 0, height: 24)
            layer.shadowRadius = 48
        }
    }
}
