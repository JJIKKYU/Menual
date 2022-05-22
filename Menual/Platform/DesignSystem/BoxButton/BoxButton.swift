//
//  BoxButton.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import Foundation
import UIKit
import Then
import SnapKit

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
        didSet { setNeedsLayout() }
    }
    
    var btnSize: BoxButtonSize = .large {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let btnLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g800
        $0.text = "텍스트를 입력해주세요"
    }
    
    init(frame: CGRect, btnStatus: BoxButtonStatus, btnSize: BoxButtonSize) {
        self.btnStatus = btnStatus
        self.btnSize = btnSize
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(btnLabel)
        AppCorner(._4pt)
        btnLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btnLabel.text = title
        
        switch btnSize {
        case .large:
            btnLabel.font = UIFont.AppTitle(.title_3)
            break
            
        case .xLarge:
            btnLabel.font = UIFont.AppTitle(.title_2)
            break
        }
        
        switch btnStatus {
        case .active:
            backgroundColor = Colors.tint.sub.n400
            btnLabel.textColor = Colors.grey.g800
            break

        case .inactive:
            backgroundColor = Colors.grey.g700
            btnLabel.textColor = Colors.grey.g500
            
            break
            
        case .pressed:
            backgroundColor = Colors.tint.sub.n600
            btnLabel.textColor = Colors.grey.g800
            break
        }
    }
}
