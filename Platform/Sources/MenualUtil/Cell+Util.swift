//
//  Cell+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import Foundation
import UIKit

extension UITableViewCell {
    public func removeSectionSeparators() {
        for subview in subviews {
            if subview != contentView && subview.frame.width == frame.width {
                subview.removeFromSuperview()
            }
        }
    }
}
