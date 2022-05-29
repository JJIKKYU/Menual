//
//  ListHeader.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then

enum ListHeaderType {
    case textandicon
    case text
    case datepageandicon
}

enum RightIconType {
    case none
    case filter
    case arrow
}

class ListHeader: UIView {
    
    private var type: ListHeaderType = .datepageandicon {
        didSet { setNeedsLayout() }
    }
    
    private var rightIconType: RightIconType = .none {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let rightArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.right.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g400
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    let rightFilterBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.filter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }

    init(type: ListHeaderType, rightIconType: RightIconType) {
        self.type = type
        self.rightIconType = rightIconType
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(rightArrowBtn)
        addSubview(rightFilterBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        titleLabel.sizeToFit()
        
        rightArrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.top.bottom.equalToSuperview()
        }
        
        rightFilterBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.text = title

        switch type {
        case .text:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            break
            
        case .textandicon:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            break
            
        case .datepageandicon:
            titleLabel.isHidden = false
            
            titleLabel.font = UIFont.AppHead(.head_4)
            titleLabel.textColor = Colors.grey.g600
            break
        }
        
        switch rightIconType {
        case .none:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true

        case .arrow:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = false
            
        case .filter:
            rightFilterBtn.isHidden = false
            rightArrowBtn.isHidden = true
        }
    }
}
