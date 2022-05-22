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

class ListHeader: UIView {
    
    private var type: ListHeaderType = .datepageandicon {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let rightArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.right.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g400
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    private let rightFilterBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.filter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }

    init(type: ListHeaderType) {
        self.type = type
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
        
        switch type {
        case .datepageandicon:
            titleLabel.isHidden = false
            titleLabel.text = "LIST HEADER"
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = false
            break
            
        case .text:
            titleLabel.isHidden = false
            titleLabel.text = "LIST HEADER"
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true
            break
            
        case .textandicon:
            titleLabel.isHidden = false
            titleLabel.text = "PAGE.999"
            titleLabel.font = UIFont.AppHead(.head_4)
            titleLabel.textColor = Colors.grey.g600
            rightFilterBtn.isHidden = false
            rightArrowBtn.isHidden = true
            break
        }
    }
}
