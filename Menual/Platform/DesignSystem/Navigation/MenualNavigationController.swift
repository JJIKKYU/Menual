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

/// 뷰마다 NavigationType 정의
enum NaviViewType {
    case main
    /// moments, search, myPage는 동일한 case로 취금
    case moments
    /// moments, search, myPage는 동일한 case로 취금
    case search
    /// moments, search, myPage는 동일한 case로 취금
    case myPage
    
    case write
    case menualDetail
    case edit
    case temporarySave
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
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    var titleLabel = UILabel().then {
        $0.text = "title"
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = .white
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
    
    var leftButton1 = UIButton().then {
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
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
        addSubview(titleLabel)
        addSubview(leftButton1)

        menualTitleImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(139)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().inset(14)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        
        rightButton1.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        
        rightButton2.snp.makeConstraints { make in
            make.trailing.equalTo(rightButton1.snp.leading).offset(-11)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        titleLabel.sizeToFit()
        
        leftButton1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
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
        case .moments, .search, .myPage:
            backButton.isHidden = false
            titleLabel.isHidden = false
        case .write:
            titleLabel.text = "메뉴얼 작성"
            backButton.isHidden = false
            rightButton2.isHidden = false
            rightButton1.isHidden = false
            titleLabel.isHidden = false
        case .menualDetail:
            break
        case .edit:
            break
        case .temporarySave:
            titleLabel.text = "임시저장"
            backButton.isHidden = false
            rightButton1.isHidden = false
            titleLabel.isHidden = false
            break
        }
    }
}
