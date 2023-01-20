//
//  CGRect+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/11/26.
//

import Foundation
import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
