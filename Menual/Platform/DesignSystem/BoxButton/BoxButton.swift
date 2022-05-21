//
//  BoxButton.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import Foundation
import UIKit
import Then

enum BoxButtonStatus {
    case active
    case inactive
    case pressed
}

enum BoxButtonSize {
    case large
    case xLarge
}

class BoxButton: UIButton {
    var btnStatus: BoxButtonStatus = .inactive {
        didSet {
            layoutSubviews()
        }
    }
    
    var btnSize: BoxButtonSize = .large {
        didSet {
            layoutSubviews()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("boxButton Init!")
        setViews()
    }
    
    func setViews() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("BoxButton layoutSubviews!")
    }
}
