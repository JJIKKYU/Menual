//
//  PasswordView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import UIKit
import Then
import SnapKit
import MenualUtil

// MARK: - PasswordViewDelegate

public protocol PasswordViewDelegate: AnyObject {
    func deleteNumber()
    func selectNumber(number: Int)
}

// MARK: - PasswordView

public class PasswordView: UIView {

    public weak var delegate: PasswordViewDelegate?

    public enum PasswordViewType {
        case check // 비밀번호 변경시에 사용
        case first
        case second
        case error
    }
    
    public enum ScreenType {
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

    var _inputView: UIView?

    override public var canBecomeFirstResponder: Bool { return true }
    override public var canResignFirstResponder: Bool { return true }

    override public var inputView: UIView? {
        set { _inputView = newValue }
        get { return _inputView }
    }

    private let titleLabel: UILabel = .init()
    private let subTitleLabel: UILabel = . init()
    private let password1: PasswordIconView = .init(type: ._default)
    private let password2: PasswordIconView = .init(type: ._default)
    private let password3: PasswordIconView = .init(type: ._default)
    private let password4: PasswordIconView = .init(type: ._default)
    
    public init() {
        super.init(frame: CGRect.zero)
        configureUI()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        titleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = MenualString.password_title_type
            $0.font = UIFont.AppTitle(.title_5)
            $0.textColor = Colors.grey.g200
        }

        subTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = MenualString.password_desc_help
            $0.setLineHeight(lineHeight: 1.14)
            $0.font = UIFont.AppBodyOnlyFont(.body_3)
            $0.textColor = Colors.tint.main.v400
            $0.numberOfLines = 2
            $0.lineBreakStrategy = .standard
            $0.textAlignment = .center
        }

        password1.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        password2.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        password3.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        password4.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setViews() {
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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(password1.snp.bottom).offset(24)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        switch type {
        case .check:
            titleLabel.text = MenualString.password_title_type
            subTitleLabel.isHidden = true
        case .first:
            subTitleLabel.textColor = Colors.tint.main.v400
            subTitleLabel.text = MenualString.password_desc_help
            titleLabel.text = MenualString.password_title_type
            if screenType == .change {
                titleLabel.text = MenualString.password_title_change
                subTitleLabel.isHidden = false
            }
        case .second:
            subTitleLabel.textColor = Colors.tint.main.v400
            subTitleLabel.text = MenualString.password_desc_help
            titleLabel.text = MenualString.password_title_more
        case .error:
            subTitleLabel.textColor = Colors.tint.system.red.r200
            subTitleLabel.text = MenualString.password_desc_notcorrect
        }
        
        switch screenType {
        case .setting:
            subTitleLabel.isHidden = false
        case .main:
            subTitleLabel.isHidden = true
            if type == .error {
                subTitleLabel.isHidden = false
                subTitleLabel.textColor = Colors.tint.system.red.r200
                subTitleLabel.text = MenualString.password_desc_notcorrect
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

// MARK: - UIKeyInput

extension PasswordView: UIKeyInput {
    public var hasText: Bool { return false }

    // 키보드로 숫자를 눌렀을 경우
    public func insertText(_ text: String) {
        guard let number: Int = Int(text) else { return }
        delegate?.selectNumber(number: number)
    }

    // 키보드로 삭제 버튼을 눌렀을 경우
    public func deleteBackward() {
        delegate?.deleteNumber()
    }
    public var keyboardType: UIKeyboardType {
        get { .numberPad }
        set { }
    }
}
