//
//  MenualNavigationController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/17.
//

import Foundation
import UIKit
import SnapKit
import Then
import MenualUtil

public protocol MenualNaviViewProtocol {
    
}

/// 뷰마다 NavigationType 정의
public enum NaviViewType {
    case main
    case moments
    case search
    case myPage
    case myPageCancel
    
    case write
    case writePicture
    case writePictureClose
    case menualDetail
    case edit
    case temporarySave
    case detailImage
}

public class MenualNaviView: UIView {
    
    public var naviViewType: NaviViewType

    public lazy var menualTitleImage = UIImageView().then {
        let image = Asset._24px.full.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.tint.main.v700
        $0.image = image
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    public var backButton = BaseButton().then {
        $0.actionName = "back"
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    public var titleLabel = UILabel().then {
        $0.text = "title"
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = .white
        $0.isHidden = true
    }
    
    // 가장 오른쪽
    public var rightButton1 = BaseButton().then {
        $0.setImage(Asset._24px.profile.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v700
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    public var rightButton1IsActive: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var rightButton2IsActive: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    // 오른쪽에서 2번째
    public var rightButton2 = BaseButton().then {
        $0.setImage(Asset._24px.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v700
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    public var leftButton1 = BaseButton().then {
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.isHidden = true
    }
    
    public init(type: NaviViewType) {
        self.naviViewType = type
        super.init(frame: CGRect.zero)
        categoryName = "navi"
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
    
    public func setNaviViewType() {
        switch naviViewType {
        case .main:
            rightButton1.actionName = "profile"
            rightButton1.isHidden = false
            rightButton2.actionName = "search"
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
            titleLabel.text = MenualString.profile_title_myPage
            titleLabel.font = UIFont.AppHead(.head_4)
            backButton.isHidden = false
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            titleLabel.isHidden = false
        case .myPageCancel:
            titleLabel.isHidden = true
            backButton.isHidden = true
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g100
            rightButton1.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        case .search:
            titleLabel.text = MenualString.search_title
            titleLabel.font = UIFont.AppHead(.head_4)
            backButton.isHidden = false
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            titleLabel.isHidden = false
        case .write:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppTitle(.title_3)
            titleLabel.text = MenualString.writing_title
            backButton.isHidden = false
            backButton.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton2.isHidden = false
            rightButton2.setImage(Asset._24px.storage.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton2.tintColor = Colors.grey.g100
            rightButton2.actionName = "tempSave"
            rightButton1.isHidden = false
            rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.tintColor = Colors.grey.g600
            rightButton1.actionName = "upload"
        case .menualDetail:
            titleLabel.isHidden = false
            titleLabel.text = MenualString.detail_title
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.actionName = "more"
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g100
            rightButton1.setImage(Asset._24px.more.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton2.actionName = "reminder"
            rightButton2.isHidden = false
            rightButton2.tintColor = Colors.grey.g100
            rightButton2.setImage(Asset._24px.Alert.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
            break
        case .edit:
            titleLabel.isHidden = false
            titleLabel.text = MenualString.writing_title_edit
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
            titleLabel.text = MenualString.tempsave_title
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.actionName = "delete"
            rightButton1.isHidden = false
            rightButton1.setImage(Asset._24px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton1.tintColor = Colors.grey.g100

        case .writePicture:
            titleLabel.isHidden = false
            titleLabel.text = MenualString.uploadimage_title_add
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = false
            backButton.tintColor = Colors.grey.g100
            backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
        case .writePictureClose:
            titleLabel.isHidden = false
            titleLabel.text = MenualString.uploadimage_title_add
            titleLabel.font = UIFont.AppTitle(.title_3)
            backButton.isHidden = true
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g100
            rightButton1.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
        case .detailImage:
            titleLabel.isHidden = false
            titleLabel.text = ""
            backgroundColor = .clear
            backButton.isHidden = true
            rightButton1.isHidden = false
            rightButton1.tintColor = Colors.grey.g100
            rightButton1.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    public override func layoutSubviews() {
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
        case .myPageCancel:
            break
        case .write, .edit:
            if rightButton1IsActive {
                rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.tint.sub.n400
                rightButton1.isUserInteractionEnabled = true
            } else {
                rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.grey.g600
                rightButton1.isUserInteractionEnabled = false
            }
            break
        case .menualDetail:
            if rightButton2IsActive {
                rightButton2.setImage(Asset._24px.Alert.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton2.tintColor = Colors.tint.sub.n400
            } else {
                rightButton2.tintColor = Colors.grey.g100
                rightButton2.setImage(Asset._24px.Alert.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            break
        case .temporarySave:
            if rightButton1IsActive {
                rightButton1.setImage(nil, for: .normal)
                rightButton1.setTitle("취소", for: .normal)
                rightButton1.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_3).withSize(14)
                rightButton1.setTitleColor(Colors.tint.system.red.r100, for: .normal)
                rightButton1.snp.updateConstraints { make in
                    make.width.equalTo(26)
                }
            } else {
                rightButton1.setTitle(nil, for: .normal)
                rightButton1.setImage(Asset._24px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
                rightButton1.tintColor = Colors.grey.g100
                rightButton1.snp.updateConstraints { make in
                    make.width.equalTo(24)
                    make.height.equalTo(24)
                }
            }
        case .writePicture, .writePictureClose:
            break
        case .detailImage:
            backgroundColor = .clear
            break
        }
    }
}
