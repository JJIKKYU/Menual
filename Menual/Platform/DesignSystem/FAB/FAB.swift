//
//  FAB.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import Foundation
import Then
import SnapKit
import UIKit

enum FABType {
    case primary
    case secondary
    case spacRequired
}

enum FABStatus {
    case default_
    case pressed
}

enum FABIsFilltered {
    case enabled
    case disabled
}

class FAB: UIButton {
    var fabType: FABType = .primary {
        didSet { setNeedsLayout() }
    }
    
    var fabStatus: FABStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    var spaceRequiredCurrentPage: String = "P.999" {
        didSet { setNeedsLayout() }
    }
    
    var isFiltered: FABIsFilltered = .disabled {
        didSet { setNeedsLayout() }
    }
    
    var leftArrowIsEnabled: Bool =  true {
        didSet { setNeedsLayout() }
    }
    
    var rightArrowIsEnabled: Bool = true {
        didSet { setNeedsLayout() }
    }
    
    private let fabIconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._24px.write.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g800
        $0.isHidden = true
    }
    
    var spaceRequiredLeftArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._20px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v500
        $0.isHidden = true
        $0.tag = -1
    }
    
    var spaceRequiredRightArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._20px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v500
        $0.isHidden = true
        $0.tag = 1
    }
    
    private let spaceRequiredCurrentPageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "P.999"
        $0.isHidden = true
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = Colors.tint.main.v500
    }
    
    override open var isHighlighted: Bool {
        didSet {
            fabStatus = isHighlighted ? .pressed : .default_
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    convenience init(fabType: FABType, fabStatus: FABStatus) {
        self.init()
        self.fabType = fabType
        self.fabStatus = fabStatus
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.tint.sub.n400
        layer.cornerRadius = 28
        AppShadow(.shadow_4)
        
        addSubview(fabIconImageView)
        addSubview(spaceRequiredLeftArrowBtn)
        addSubview(spaceRequiredRightArrowBtn)
        addSubview(spaceRequiredCurrentPageLabel)
        
        fabIconImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        spaceRequiredLeftArrowBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        spaceRequiredCurrentPageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        spaceRequiredRightArrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch fabType {
        case .primary:
            fabIconImageView.tintColor = Colors.grey.g800
            fabIconImageView.isHidden = false
            
            switch isFiltered {
            case .enabled:
                fabIconImageView.image = Asset._24px.Circle.front .image.withRenderingMode(.alwaysTemplate)
                backgroundColor = Colors.tint.main.v400
            case .disabled:
                fabIconImageView.image = Asset._24px.write.image.withRenderingMode(.alwaysTemplate)
                backgroundColor = Colors.tint.sub.n400
            }
            
            switch fabStatus {
            case .default_:
                switch isFiltered {
                case .enabled:
                    backgroundColor = Colors.tint.main.v400
                case .disabled:
                    backgroundColor = Colors.tint.sub.n400
                }

            case .pressed:
                switch isFiltered {
                case .enabled:
                    backgroundColor = Colors.tint.main.v600
                case .disabled:
                    backgroundColor = Colors.tint.sub.n600
                }
            }
            
        case .secondary:
            fabIconImageView.image = Asset._24px.Arrow.Up.big.image.withRenderingMode(.alwaysTemplate)
            fabIconImageView.tintColor = Colors.grey.g400
            fabIconImageView.isHidden = false
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.grey.g800
            case .pressed:
                backgroundColor = Colors.grey.g700
            }

        case .spacRequired:
            spaceRequiredCurrentPageLabel.isHidden = false
            spaceRequiredLeftArrowBtn.isHidden = false
            spaceRequiredRightArrowBtn.isHidden = false
            
            AppShadow(.shadow_4)
            layer.borderColor = Colors.tint.main.v700.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = frame.height / 2
            
            spaceRequiredCurrentPageLabel.text = "P." + spaceRequiredCurrentPage
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.background
            case .pressed:
                backgroundColor = Colors.grey.g800
            }
            
        }
        
        switch leftArrowIsEnabled {
        case true:
            spaceRequiredLeftArrowBtn.isUserInteractionEnabled = true
            spaceRequiredLeftArrowBtn.tintColor = Colors.tint.main.v500
        case false:
            spaceRequiredLeftArrowBtn.isUserInteractionEnabled = false
            spaceRequiredLeftArrowBtn.tintColor = Colors.grey.g700
        }
        
        switch rightArrowIsEnabled {
        case true:
            spaceRequiredRightArrowBtn.isUserInteractionEnabled = true
            spaceRequiredRightArrowBtn.tintColor = Colors.tint.main.v500
        case false:
            spaceRequiredRightArrowBtn.isUserInteractionEnabled = false
            spaceRequiredRightArrowBtn.tintColor = Colors.grey.g700
        }
    }
}
