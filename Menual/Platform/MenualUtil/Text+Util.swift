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
}

enum BodyType {
    case body_4
    case body_3
    case body_2
    case body_1
}

extension UIFont {
    // SpoqaHanSansNeo의 폰트 타입에 따라 폰트 이름 리턴
    class func SpoqaHanSansNeo(_ type: SpoqaHanSansNeoType) -> String {
        switch type {
        case .Regular:
            return "AppleSDGothicNeo-Regular"
        case .Bold:
            return "AppleSDGothicNeo-Bold"
        }
    }
    
    // Montserrat의 폰트 타입에 따라 폰트 이름 리턴
    class func Montserrat(_ type: MontserratType) -> String {
        switch type {
        case .ExtraBold:
            return ""
        }
    }
    
    // 디자인 시스템에 정의되어 있는 타이틀 리턴
    class func AppTitle(_ title: TitleType) {
        switch title {
        case .title_1:
            break
        case .title_2:
            break
        case .title_3:
            break
        case .title_4:
            break
        case .title_5:
            break
        }
    }
    
    // 디자인 시스템에 정의되어 있는 바디 리턴
    class func AppBody(_ body: BodyType) {
        switch body {
        case .body_4:
            break
        case .body_3:
            break
        case .body_2:
            break
        case .body_1:
            break
        }
    }
}
