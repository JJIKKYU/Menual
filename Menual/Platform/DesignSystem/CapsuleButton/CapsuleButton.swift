//
//  CapsuleButton.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import Then
import SnapKit

enum CapsuleButtonStatus {
    case defaultType
    case pressed
}

enum CapsuleButtonIncludeType {
    case textOnly
    case iconText
}

class CapsuleButton: UIButton {
    var includeType: CapsuleButtonIncludeType = .textOnly {
        didSet { setNeedsLayout() }
    }
    
    var buttonStatus: CapsuleButtonStatus = .defaultType {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var image: UIImage = UIImage() {
        didSet { setNeedsLayout() }
    }
    
    var btnSelected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    private let leftImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._16px.Circle.front.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g500
        $0.contentMode = .scaleAspectFit
    }
    
    private let rightTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g500
        $0.font = UIFont.AppTitle(.title_1)
    }
    
    init(frame: CGRect, includeType: CapsuleButtonIncludeType) {
        self.includeType = includeType
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(leftImageView)
        addSubview(rightTitleLabel)
        
        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(16)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(6)
        }
        
        rightTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rightTitleLabel.text = title
        leftImageView.image = image
        
        switch btnSelected {
        case true:
            self.buttonStatus = .pressed
        case false:
            self.buttonStatus = .defaultType
        }
        
        switch includeType {
        case .textOnly:
            leftImageView.isHidden = true
            break
        case .iconText:
            leftImageView.isHidden = false
            break
        }
        
        switch buttonStatus {
        case .defaultType:
            backgroundColor = Colors.grey.g800
            rightTitleLabel.textColor = Colors.grey.g500
            break
        case .pressed:
            backgroundColor = Colors.grey.g700
            break
        }
        
        layer.cornerRadius = self.frame.height / 2
    }
}
