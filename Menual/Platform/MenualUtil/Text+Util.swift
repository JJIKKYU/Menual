//
//  Text+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/02/26.
//

import Foundation
import UIKit

enum SpoqaHanSansNeoType {
    case Regular
    case Bold
}

enum MontserratType {
    case ExtraBold
}

enum TitleType {
    case title_1
    case title_2
    case title_3
    case title_4
    case title_5
    case title_6
}

enum BodyType {
    case body_4
    case body_3
    case body_2
    case body_1
}

enum HeadType {
    case head_1
    case head_2
    case head_3
    case head_4
    case head_5
}

var systemLineHeight: CGFloat{ 1.44}

extension UIFont {
    
    // SpoqaHanSansNeo의 폰트 타입에 따라 폰트 이름 리턴
    class func SpoqaHanSansNeo(_ type: SpoqaHanSansNeoType) -> String {
        switch type {
        case .Regular:
            return "SpoqaHanSansNeo-Regular"
        case .Bold:
            return "SpoqaHanSansNeo-Bold"
        }
    }
    
    // Montserrat의 폰트 타입에 따라 폰트 이름 리턴
    class func Montserrat(_ type: MontserratType) -> String {
        switch type {
        case .ExtraBold:
            return "Montserrat-ExtraBold"
        }
    }
    
    // 디자인 시스템에 정의되어 있는 타이틀 리턴
    class func AppTitle(_ title: TitleType) -> UIFont! {
        switch title {
        case .title_1:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 12)
        case .title_2:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 14)
        case .title_3:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 16)
        case .title_4:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 18)
        case .title_5:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 21)
        case .title_6:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Bold), size: 24)
        }
    }
    
    // 디자인 시스템에 정의되어 있는 타이틀 리턴
    class func AppBodyOnlyFont(_ body: BodyType) -> UIFont! {
        switch body {
        case .body_4:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 16)
        case .body_3:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 14)
        case .body_2:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 12)
        case .body_1:
            return UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 10)
        }
    }
    
    // 디자인 시스템에 정의되어 있는 바디 리턴
    class func AppBody(_ body: BodyType, _ color: UIColor) -> [NSAttributedString.Key:Any] {
        var font: UIFont?
        
        switch body {
        case .body_4:
            font = UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 16)
        case .body_3:
            font = UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 14)
        case .body_2:
            font = UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 12)
        case .body_1:
            font = UIFont(name: UIFont.SpoqaHanSansNeo(.Regular), size: 10)
        }
        
        // 행간 조절
        // paragraphStyle.lineHeightMultiple = 1.28
        
        return [
            .font: font!,
            .paragraphStyle : NSMutableParagraphStyle().then {
                $0.lineHeightMultiple = systemLineHeight
            },
            .foregroundColor : color
        ]
    }
    
    // 디자인 시스템에 정의되어 있는 헤드 리턴
    class func AppHead(_ head: HeadType) -> UIFont! {
        switch head {
        case .head_1:
            return UIFont(name: UIFont.Montserrat(.ExtraBold), size: 10)
        case .head_2:
            return UIFont(name: UIFont.Montserrat(.ExtraBold), size: 12)
        case .head_3:
            return UIFont(name: UIFont.Montserrat(.ExtraBold), size: 14)
        case .head_4:
            return UIFont(name: UIFont.Montserrat(.ExtraBold), size: 16)
        case .head_5:
            return UIFont(name: UIFont.Montserrat(.ExtraBold), size: 18)
        }
    }
}

extension UILabel {
    func setLineHeight(lineHeight: CGFloat = systemLineHeight) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment

        let attrString = NSMutableAttributedString()
        if (self.attributedText != nil) {
            attrString.append( self.attributedText!)
        } else {
            attrString.append( NSMutableAttributedString(string: self.text!))
            attrString.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSMakeRange(0, attrString.length))
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}
