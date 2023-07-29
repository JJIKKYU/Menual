//
//  Corner+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/03/16.
//

import Foundation
import UIKit

public enum CornerType {
    case _2pt
    case _4pt
    case _6pt
    case tiny
    case small
    case base
    case middle
    case large
}

public extension UIView {
    /**
     CornerRadius System
     */
    func AppCorner(_ type: CornerType) {
        switch type {
        case ._2pt:
            layer.cornerRadius = 2
        case ._4pt:
            layer.cornerRadius = 4
        case ._6pt:
            layer.cornerRadius = 6
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
