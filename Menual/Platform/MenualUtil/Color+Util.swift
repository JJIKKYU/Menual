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
    
    static func AppColor(_ name: ColorStyle) -> UIColor {
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

enum Colors {

    enum main {

        enum tint {

            static var c100: UIColor {
                return color(
                    dark: UIColor(red: 0.9843137264251709, green: 0.9843137264251709, blue: 0.7882353067398071, alpha: 1),
                    light: UIColor(red: 0.9921568632125854, green: 0.9921568632125854, blue: 0.8941176533699036, alpha: 1)
                )
            }

            static var c200: UIColor {
                return color(
                    dark: UIColor(red: 0.9725490212440491, green: 0.9686274528503418, blue: 0.5803921818733215, alpha: 1),
                    light: UIColor(red: 0.9764705896377563, green: 0.9764705896377563, blue: 0.6823529601097107, alpha: 1)
                )
            }

            static var c300: UIColor {
                return color(
                    dark: UIColor(red: 0.95686274766922, green: 0.95686274766922, blue: 0.3686274588108063, alpha: 1),
                    light: UIColor(red: 0.9647058844566345, green: 0.9607843160629272, blue: 0.4745098054409027, alpha: 1)
                )
            }

            static var c400: UIColor {
                return color(
                    dark: UIColor(red: 0.9411764740943909, green: 0.9400390386581421, blue: 0.1568627506494522, alpha: 1),
                    light: UIColor(red: 0.95686274766922, green: 0.9529411792755127, blue: 0.1411764770746231, alpha: 1)
                )
            }

            static var c500: UIColor {
                return color(
                    dark: UIColor(red: 0.8980392217636108, green: 0.8980392217636108, blue: 0.062745101749897, alpha: 1),
                    light: UIColor(red: 0.6431372761726379, green: 0.6392157077789307, blue: 0.04313725605607033, alpha: 1)
                )
            }

            static var c600: UIColor {
                return color(
                    dark: UIColor(red: 0.7686274647712708, green: 0.7686274647712708, blue: 0.054901961237192154, alpha: 1),
                    light: UIColor(red: 0.5137255191802979, green: 0.5137255191802979, blue: 0.03529411926865578, alpha: 1)
                )
            }

            static var c700: UIColor {
                return color(
                    dark: UIColor(red: 0.6431372761726379, green: 0.6392157077789307, blue: 0.04313725605607033, alpha: 1),
                    light: UIColor(red: 0.3843137323856354, green: 0.3843137323856354, blue: 0.027450980618596077, alpha: 1)
                )
            }

            static var c800: UIColor {
                return color(
                    dark: UIColor(red: 0.5137255191802979, green: 0.5137255191802979, blue: 0.03529411926865578, alpha: 1),
                    light: UIColor(red: 0.2549019753932953, green: 0.2549019753932953, blue: 0.019607843831181526, alpha: 1)
                )
            }
        }

        enum sub {

            static var c100: UIColor {
                return color(
                    dark: UIColor(red: 0.9843137264251709, green: 0.886274516582489, blue: 0.7882353067398071, alpha: 1),
                    light: UIColor(red: 0.9921568632125854, green: 0.9450980424880981, blue: 0.8941176533699036, alpha: 1)
                )
            }

            static var c200: UIColor {
                return color(
                    dark: UIColor(red: 0.9725490212440491, green: 0.7764706015586853, blue: 0.5803921818733215, alpha: 1),
                    light: UIColor(red: 0.9764705896377563, green: 0.8313725590705872, blue: 0.6823529601097107, alpha: 1)
                )
            }

            static var c300: UIColor {
                return color(
                    dark: UIColor(red: 0.95686274766922, green: 0.6627451181411743, blue: 0.3686274588108063, alpha: 1),
                    light: UIColor(red: 0.9647058844566345, green: 0.7176470756530762, blue: 0.4745098054409027, alpha: 1)
                )
            }

            static var c400: UIColor {
                return color(
                    dark: UIColor(red: 0.9411764740943909, green: 0.5490196347236633, blue: 0.1568627506494522, alpha: 1),
                    light: UIColor(red: 0.95686274766922, green: 0.5490196347236633, blue: 0.1411764770746231, alpha: 1)
                )
            }

            static var c500: UIColor {
                return color(
                    dark: UIColor(red: 0.8980392217636108, green: 0.48235294222831726, blue: 0.062745101749897, alpha: 1),
                    light: UIColor(red: 0.6431372761726379, green: 0.3450980484485626, blue: 0.04313725605607033, alpha: 1)
                )
            }

            static var c600: UIColor {
                return color(
                    dark: UIColor(red: 0.7686274647712708, green: 0.4117647111415863, blue: 0.054901961237192154, alpha: 1),
                    light: UIColor(red: 0.5137255191802979, green: 0.27450981736183167, blue: 0.03529411926865578, alpha: 1)
                )
            }

            static var c700: UIColor {
                return color(
                    dark: UIColor(red: 0.6431372761726379, green: 0.3450980484485626, blue: 0.04313725605607033, alpha: 1),
                    light: UIColor(red: 0.3843137323856354, green: 0.2078431397676468, blue: 0.027450980618596077, alpha: 1)
                )
            }

            static var c800: UIColor {
                return color(
                    dark: UIColor(red: 0.5137255191802979, green: 0.27450981736183167, blue: 0.03529411926865578, alpha: 1),
                    light: UIColor(red: 0.2549019753932953, green: 0.13725490868091583, blue: 0.019607843831181526, alpha: 1)
                )
            }
        }
    }

    enum system {

        enum blue {

            static var c100: UIColor {
                return color(
                    dark: UIColor(red: 0.14901961386203766, green: 0.5176470875740051, blue: 1, alpha: 1),
                    light: UIColor(red: 0, green: 0.3960784375667572, blue: 1, alpha: 1)
                )
            }

            static var c200: UIColor {
                return color(
                    dark: UIColor(red: 0, green: 0.3960784375667572, blue: 1, alpha: 1),
                    light: UIColor(red: 0, green: 0.32156863808631897, blue: 0.800000011920929, alpha: 1)
                )
            }
        }

        enum red {

            static var c100: UIColor {
                return color(
                    dark: UIColor(red: 1, green: 0.45490196347236633, blue: 0.32156863808631897, alpha: 1),
                    light: UIColor(red: 1, green: 0.33725491166114807, blue: 0.1882352977991104, alpha: 1)
                )
            }

            static var c200: UIColor {
                return color(
                    dark: UIColor(red: 1, green: 0.33725491166114807, blue: 0.1882352977991104, alpha: 1),
                    light: UIColor(red: 0.8705882430076599, green: 0.2078431397676468, blue: 0.04313725605607033, alpha: 1)
                )
            }
        }

        enum yellow {

            static var c100: UIColor {
                return color(
                    dark: UIColor(red: 1, green: 0.8901960849761963, blue: 0.501960813999176, alpha: 1),
                    light: UIColor(red: 1, green: 0.7686274647712708, blue: 0, alpha: 1)
                )
            }

            static var c200: UIColor {
                return color(
                    dark: UIColor(red: 1, green: 0.7686274647712708, blue: 0, alpha: 1),
                    light: UIColor(red: 1, green: 0.6705882549285889, blue: 0, alpha: 1)
                )
            }
        }
    }

    enum grey {

        static var c100: UIColor {
            return color(
                dark: UIColor(red: 0.9019607901573181, green: 0.9019607901573181, blue: 0.9019607901573181, alpha: 1),
                light: UIColor(red: 0.9529411792755127, green: 0.9529411792755127, blue: 0.9529411792755127, alpha: 1)
            )
        }

        static var c200: UIColor {
            return color(
                dark: UIColor(red: 0.8039215803146362, green: 0.8039215803146362, blue: 0.8039215803146362, alpha: 1),
                light: UIColor(red: 0.8549019694328308, green: 0.8549019694328308, blue: 0.8549019694328308, alpha: 1)
            )
        }

        static var c300: UIColor {
            return color(
                dark: UIColor(red: 0.7058823704719543, green: 0.7058823704719543, blue: 0.7058823704719543, alpha: 1),
                light: UIColor(red: 0.7568627595901489, green: 0.7568627595901489, blue: 0.7568627595901489, alpha: 1)
            )
        }

        static var c400: UIColor {
            return color(
                dark: UIColor(red: 0.6078431606292725, green: 0.6078431606292725, blue: 0.6078431606292725, alpha: 1),
                light: UIColor(red: 0.658823549747467, green: 0.658823549747467, blue: 0.658823549747467, alpha: 1)
            )
        }

        static var c500: UIColor {
            return color(
                dark: UIColor(red: 0.5333333611488342, green: 0.5333333611488342, blue: 0.5333333611488342, alpha: 1),
                light: UIColor(red: 0.3803921639919281, green: 0.3803921639919281, blue: 0.3803921639919281, alpha: 1)
            )
        }

        static var c600: UIColor {
            return color(
                dark: UIColor(red: 0.45490196347236633, green: 0.45490196347236633, blue: 0.45490196347236633, alpha: 1),
                light: UIColor(red: 0.30588236451148987, green: 0.30588236451148987, blue: 0.30588236451148987, alpha: 1)
            )
        }

        static var c700: UIColor {
            return color(
                dark: UIColor(red: 0.3803921639919281, green: 0.3803921639919281, blue: 0.3803921639919281, alpha: 1),
                light: UIColor(red: 0.22745098173618317, green: 0.22745098173618317, blue: 0.22745098173618317, alpha: 1)
            )
        }

        static var c800: UIColor {
            return color(
                dark: UIColor(red: 0.30588236451148987, green: 0.30588236451148987, blue: 0.30588236451148987, alpha: 1),
                light: UIColor(red: 0.15294118225574493, green: 0.15294118225574493, blue: 0.15294118225574493, alpha: 1)
            )
        }
    }
}

extension Colors {

    static func color(dark: UIColor, light: UIColor) -> UIColor {
        guard #available(iOS 13, *) else { return light }
        
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            switch UITraitCollection.userInterfaceStyle {
            case .dark: return dark
            case .light: return light
            default: return light
            }
        }
    }
}

