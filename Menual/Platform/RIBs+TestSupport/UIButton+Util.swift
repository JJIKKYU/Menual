//
//  UIButton+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import Foundation
import UIKit

extension UIButton {

    // Status별 backgRoundColor 지정
    func setBackgroundColor(_ color: UIColor, for forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}
