//
//  PasswordView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import UIKit
import Then
import SnapKit

class PasswordView: UIView {
    
    enum PasswordViewType {
        case check // 비밀번호 변경시에 사용
        case first
        case second
        case error
    }
    
    enum ScreenType {
        case setting
        case main
        case change
    }
    
    public var type: PasswordViewType = .first {
        didSet { setNeedsLayout() }
    }
    
    public var screenType: ScreenType = .setting {
        didSet { setNeedsLayout() }
    }
    
    public var numberArr: [Int] = [] {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = MenualString.password_title_type
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g200
    }
    
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = MenualString.password_desc_help
        $0.setLineHeight(lineHeight: 1.14)
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = Colors.tint.main.v400
        $0.numberOfLines = 2
        $0.lineBreakStrategy = .standard
        $0.textAlignment = .center
    }
    
    private let password1 = PasswordIconView(type: ._default).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let password2 = PasswordIconView(type: ._default).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let password3 = PasswordIconView(type: ._default).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let password4 = PasswordIconView(type: ._default).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(password1)
        addSubview(password2)
        addSubview(password3)
        addSubview(password4)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        password1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(33)
            make.height.equalTo(88)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        password2.snp.makeConstraints { make in
            make.leading.equalTo(password1.snp.trailing).offset(32)
            make.width.equalTo(33)
            make.height.equalTo(88)
            make.top.equalTo(password1)
        }
        
        password3.snp.makeConstraints { make in
            make.leading.equalTo(password2.snp.trailing).offset(32)
            make.width.equalTo(33)
            make.height.equalTo(88)
            make.top.equalTo(password1)
        }
        
        password4.snp.makeConstraints { make in
            make.leading.equalTo(password3.snp.trailing).offset(32)
            make.width.equalTo(33)
            make.height.equalTo(88)
            make.top.equalTo(password1)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(password1.snp.bottom).offset(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch type {
        case .check:
            titleLabel.text = "비밀번호를 입력해 주세요"
            subTitleLabel.isHidden = true
        case .first:
            subTitleLabel.textColor = Colors.tint.main.v400
            subTitleLabel.text = "비밀번호를 분실 시 찾을 수 없으니 신중하게 입력해 주세요!"
            titleLabel.text = "비밀번호를 입력해 주세요"
            if screenType == .change {
                titleLabel.text = "변경할 비밀번호를 입력해 주세요"
                subTitleLabel.isHidden = false
            }
        case .second:
            subTitleLabel.textColor = Colors.tint.main.v400
            subTitleLabel.text = "비밀번호를 분실 시 찾을 수 없으니 신중하게 입력해 주세요!"
            titleLabel.text = "한 번 더 입력해 주세요"
        case .error:
            subTitleLabel.textColor = Colors.tint.system.red.r200
            subTitleLabel.text = "비밀번호가 올바르지 않습니다"
        }
        
        switch screenType {
        case .setting:
            subTitleLabel.isHidden = false
        case .main:
            subTitleLabel.isHidden = true
            if type == .error {
                subTitleLabel.isHidden = false
                subTitleLabel.textColor = Colors.tint.system.red.r200
                subTitleLabel.text = "비밀번호가 맞지 않아요."
            }
        case .change:
            break
        }
        
        print("PasswordView :: numberArr = \(numberArr)")
        
        // error가 아닐 경우 하나씩 반응하도록
        if type != .error {
            password1.type = ._default
            password2.type = ._default
            password3.type = ._default
            password4.type = ._default
            
            switch numberArr.count {
            case 0:
                break
                
            case 1:
                password1.type = .typed
                
            case 2:
                password1.type = .typed
                password2.type = .typed
                
            case 3:
                password1.type = .typed
                password2.type = .typed
                password3.type = .typed
                
            case 4:
                password1.type = .typed
                password2.type = .typed
                password3.type = .typed
                password4.type = .typed
                
            default:
                break
            }
        } else {
            password1.type = .error
            password2.type = .error
            password3.type = .error
            password4.type = .error
        }
        
    }
}
