//
//  Color+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/02/26.
//

import Foundation
import UIKit

enum ColorStyle {
    // 메인컬러
    case tint_main_100
    case tint_main_200
    case tint_main_300
    case tint_main_400
    case tint_main_500
    case tint_main_600
    case tint_main_700
    case tint_main_800
    
    // 서브컬러
    case tint_sub_100
    case tint_sub_200
    case tint_sub_300
    case tint_sub_400
    case tint_sub_500
    case tint_sub_600
    case tint_sub_700
    case tint_sub_800
    
    // 시스템컬러
    case system_blue_100
    case system_blue_200
    case system_red_100
    case system_red_200
    case system_yellow_100
    case system_yellow_200
    
    // 그레이컬러
    case grey_100
    case grey_200
    case grey_300
    case grey_400
    case grey_500
    case grey_600
    case grey_700
    case grey_800
    
    // 기본컬러
    case white
    case black
}

extension UIColor {
    // 255/255/255 로 컬러초기화 가능
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    static func appColor(_ name: ColorStyle) -> UIColor {
        var isDarkMode: Bool = false
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                isDarkMode = true
            }
        }
        
        switch name {
        case .tint_main_100:
            return isDarkMode ? UIColor(red: 38, green: 132, blue: 255) : UIColor.red
        case .tint_main_200:
            return UIColor()
        case .tint_main_300:
            return UIColor()
        case .tint_main_400:
            return UIColor()
        case .tint_main_500:
            return UIColor()
        case .tint_main_600:
            return UIColor()
        case .tint_main_700:
            return UIColor()
        case .tint_main_800:
            return UIColor()
            
        case .tint_sub_100:
            return UIColor()
        case .tint_sub_200:
            return UIColor()
        case .tint_sub_300:
            return UIColor()
        case .tint_sub_400:
            return UIColor()
        case .tint_sub_500:
            return UIColor()
        case .tint_sub_600:
            return UIColor()
        case .tint_sub_700:
            return UIColor()
        case .tint_sub_800:
            return UIColor()
            
        case .system_blue_100:
            return UIColor()
        case .system_blue_200:
            return UIColor()
        case .system_red_100:
            return UIColor()
        case .system_red_200:
            return UIColor()
        case .system_yellow_100:
            return UIColor()
        case .system_yellow_200:
            return UIColor()
            
        case .grey_100:
            return UIColor()
        case .grey_200:
            return UIColor()
        case .grey_300:
            return UIColor()
        case .grey_400:
            return UIColor()
        case .grey_500:
            return UIColor()
        case .grey_600:
            return UIColor()
        case .grey_700:
            return UIColor()
        case .grey_800:
            return UIColor()
        case .white:
            return UIColor()
        case .black:
            return UIColor()
        }
    }
}
