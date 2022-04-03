//
//  Corner+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/03/16.
//

import Foundation
import UIKit

enum CornerType {
    case tiny
    case small
    case base
    case middle
    case large
}

extension UIView {
    /**
     CornerRadius System
     */
    func AppCorner(_ type: CornerType) {
        switch type {
        case .tiny:
            layer.cornerRadius = 8
        case .small:
            layer.cornerRadius = 12
        case .base:
            layer.cornerRadius = 16
        case .middle:
            layer.cornerRadius = 20
        case .large:
            layer.cornerRadius = 24
        }
    }
}
