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
import MenualUtil

public enum FABType {
    case primary
    case primaryFilter
    case secondary
    case spacRequired
}

public enum FABStatus {
    case default_
    case pressed
}

public enum FABIsFilltered {
    case enabled
    case disabled
}

public class FAB: UIButton {

    public var fabType: FABType = .primary {
        didSet { setNeedsLayout() }
    }
    
    public var fabStatus: FABStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    public var spaceRequiredCurrentPage: String = "P.999" {
        didSet { setNeedsLayout() }
    }
    
    public var isFiltered: FABIsFilltered = .disabled {
        didSet { setNeedsLayout() }
    }
    
    public var leftArrowIsEnabled: Bool =  true {
        didSet { setNeedsLayout() }
    }
    
    public var rightArrowIsEnabled: Bool = true {
        didSet { setNeedsLayout() }
    }
    
    private let fabIconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._24px.write.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g800
        $0.isHidden = true
    }
    
    public var spaceRequiredLeftArrowBtn = BaseButton().then {
        $0.actionName = "left"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._20px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v500
        $0.isHidden = true
        $0.tag = -1
    }
    
    public var spaceRequiredRightArrowBtn = BaseButton().then {
        $0.actionName = "right"
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
    
    public let btnBadge = Badges().then {
        $0.badgeType = .dot
        $0.isHidden = true
    }
    
    override open var isHighlighted: Bool {
        didSet {
            fabStatus = isHighlighted ? .pressed : .default_
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    public convenience init(fabType: FABType, fabStatus: FABStatus) {
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
        addSubview(btnBadge)
        
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
        
        btnBadge.snp.makeConstraints { make in
            make.trailing.top.equalTo(fabIconImageView)
            make.width.height.equalTo(4)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        switch fabType {
        case .primary:
            fabIconImageView.tintColor = Colors.grey.g800
            fabIconImageView.isHidden = false
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.tint.sub.n400

            case .pressed:
                backgroundColor = Colors.tint.sub.n600
            }
            
        case .primaryFilter:
            fabIconImageView.image = Asset._24px.filter.image.withRenderingMode(.alwaysTemplate)
            fabIconImageView.tintColor = Colors.grey.g800
            fabIconImageView.isHidden = false
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.tint.main.v400

            case .pressed:
                backgroundColor = Colors.tint.main.v600
            }
            
            switch isFiltered {
            case .enabled:
                btnBadge.isHidden = false

            case .disabled:
                btnBadge.isHidden = true
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
                backgroundColor = Colors.background
                // backgroundColor = Colors.grey.g800
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
