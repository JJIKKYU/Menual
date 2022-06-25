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
    case search
}

enum RightIconType {
    case none
    case filter
    case arrow
    case searchDelete
}

class ListHeader: UIView {
    
    private var type: ListHeaderType = .datepageandicon {
        didSet { setNeedsLayout() }
    }
    
    private var rightIconType: RightIconType = .none {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "        " {
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
    
    let rightTextBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("기록 삭제", for: .normal)
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
        $0.setTitleColor(Colors.grey.g500, for: .normal)
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
        addSubview(rightTextBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        titleLabel.sizeToFit()
        
        rightArrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            // make.top.bottom.equalToSuperview()
        }
        
        rightFilterBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            // make.top.bottom.equalToSuperview()
        }
        
        rightTextBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(47)
            make.height.equalTo(15)
        }
        rightTextBtn.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.text = title

        switch type {
        case .text:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            
        case .textandicon:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            
        case .datepageandicon:
            titleLabel.isHidden = false
            
            titleLabel.font = UIFont.AppHead(.head_4)
            titleLabel.textColor = Colors.grey.g600

        case .search:
            titleLabel.isHidden = false
            
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g500
            
            if title.count > 6 {
                let attributedString = NSMutableAttributedString(string: title)
                let number = (title as NSString).substring(with: NSMakeRange(6, 1))
                
                attributedString.addAttribute(.foregroundColor, value: Colors.tint.main.v600, range: (title as NSString).range(of: number))
                titleLabel.attributedText = attributedString
            }
        }
        
        switch rightIconType {
        case .none:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true

        case .arrow:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = false
            rightTextBtn.isHidden = true
            
        case .filter:
            rightFilterBtn.isHidden = false
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true
            
        case .searchDelete:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = false
            
        }
    }
}
