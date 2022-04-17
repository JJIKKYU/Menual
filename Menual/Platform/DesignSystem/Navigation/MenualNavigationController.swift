//
//  MenualNavigationController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/17.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa

public protocol MenualNaviViewProtocol {
    
}

enum NaviViewType {
    case main
    case moments
}

class MenualNaviView: UIView {
    
    var naviViewType: NaviViewType

    let menualTitleImage = UIImageView().then {
        let image = Asset._24px.full.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.tint.main.v700
        $0.image = image
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    var backButton = UIButton().then {
        $0.setImage(Asset._24px.Arrow.back.image, for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    // 가장 오른쪽
    var rightButton1 = UIButton().then {
        $0.setImage(Asset._24px.profile.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v700
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    // 오른쪽에서 2번째
    var rightButton2 = UIButton().then {
        $0.setImage(Asset._24px.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v700
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    init(type: NaviViewType) {
        self.naviViewType = type
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        applyBlurEffect()
        addSubview(menualTitleImage)
        addSubview(backButton)
        addSubview(rightButton1)
        addSubview(rightButton2)

        menualTitleImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(139)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().inset(8)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        rightButton1.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        rightButton2.snp.makeConstraints { make in
            make.trailing.equalTo(rightButton1.snp.leading).offset(-11)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        setNaviViewType()
    }
    
    func setNaviViewType() {
        switch naviViewType {
        case .main:
            rightButton1.isHidden = false
            rightButton2.isHidden = false
            menualTitleImage.isHidden = false
        case .moments:
            backButton.isHidden = false
            break
        }
    }
}
