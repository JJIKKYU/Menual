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
    case moments
    case search
    case myPage
    
    case write
    case menualDetail
    case edit
    case temporarySave
}

class MenualNaviView: UIView {
    
    var naviViewType: NaviViewType

    lazy var menualTitleImage = UIImageView().then {
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
    
    var rightButton1IsActive: Bool = false {
        didSet { setNeedsLayout() }
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
        // backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        // applyBlurEffect()
        backgroundColor = Colors.background
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
        case .moments:
            titleLabel.text = "MOMENTS"
            titleLabel.font = UIFont.AppHead(.head_4)
            backButton.isHidden = false
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            titleLabel.isHidden = false
        case .myPage:
            titleLabel.text = "MY PAGE"
            titleLabel.font = UIFont.AppHead(.head_4)
            backButton.isHidden = false
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            titleLabel.isHidden = false
        case .search:
            titleLabel.text = "SEARCH"
            titleLabel.font = UIFont.AppHead(.head_4)
            backButton.isHidden = false
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            titleLabel.isHidden = false
        case .write:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppTitle(.title_3)
            titleLabel.text = "메뉴얼 작성"
            backButton.isHidden = false
            rightButton2.isHidden = false
            rightButton2.setImage(Asset._24px.storage.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton2.tintColor = Colors.grey.g100
            rightButton1.isHidden = false
            rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.tintColor = Colors.grey.g600
        case .menualDetail:
            titleLabel.isHidden = false
            titleLabel.text = "메뉴얼 상세"
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g100
            rightButton1.setImage(Asset._24px.Alert.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton2.isHidden = true
            break
        case .edit:
            titleLabel.isHidden = false
            titleLabel.text = "메뉴얼 수정"
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g600
            rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.isUserInteractionEnabled = false
            break
        case .temporarySave:
            titleLabel.isHidden = false
            titleLabel.text = "임시저장"
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.isHidden = false
            rightButton1.setImage(Asset._24px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.tintColor = Colors.grey.g100
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch naviViewType {
        case .main:
            break
        case .moments:
            break
        case .search:
            break
        case .myPage:
            break
        case .write:
            if rightButton1IsActive {
                rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.grey.g100
                rightButton1.isUserInteractionEnabled = true
            } else {
                rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.grey.g600
                rightButton1.isUserInteractionEnabled = false
            }
            break
        case .menualDetail:
            if rightButton1IsActive {
                rightButton1.setImage(Asset._24px.Alert.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.tint.sub.n400
            } else {
                rightButton1.tintColor = Colors.grey.g100
                rightButton1.setImage(Asset._24px.Alert.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            break
        case .edit:
            if rightButton1IsActive {
                rightButton1.tintColor = Colors.grey.g100
                rightButton1.isUserInteractionEnabled = true
            } else {
                rightButton1.tintColor = Colors.grey.g600
                rightButton1.isUserInteractionEnabled = false
            }
            break
        case .temporarySave:
            break
        }
    }
}
