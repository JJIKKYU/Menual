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

// 필터가 적용되면서 색상이 변경되는 경우가 있음
enum BoxButtonIsFiltered {
    case enabled
    case disabled
}

class BoxButton: UIButton {
    var btnStatus: BoxButtonStatus = .inactive {
        didSet { setNeedsLayout() }
    }
    
    var btnSize: BoxButtonSize = .large {
        didSet { setNeedsLayout() }
    }
    
    var isFiltered: BoxButtonIsFiltered = .disabled {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var btnSelected: Bool = false {
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
            btnLabel.textColor = Colors.grey.g800

            if btnSize == .xLarge {
                switch isFiltered {
                case .enabled:
                    backgroundColor = Colors.tint.main.v400
                case .disabled:
                    backgroundColor = Colors.tint.sub.n400
                }
            } else {
                backgroundColor = Colors.tint.sub.n400
            }

        case .inactive:
            backgroundColor = Colors.grey.g700
            btnLabel.textColor = Colors.grey.g500
            
            break
            
        case .pressed:
            btnLabel.textColor = Colors.grey.g800
            
            if btnSize == .xLarge {
                switch isFiltered {
                case .enabled:
                    backgroundColor = Colors.tint.main.v400
                case .disabled:
                    backgroundColor = Colors.tint.sub.n400
                }
            } else {
                backgroundColor = Colors.tint.sub.n400
            }
        }
        
        if btnStatus == .inactive { return }
        switch btnSelected {
        case true:
            btnStatus = .pressed
            
        case false:
            btnStatus = .active
        }
    }
}
