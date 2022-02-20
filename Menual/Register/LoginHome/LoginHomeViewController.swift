//
//  LoginHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift
import UIKit

protocol LoginHomePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedRegisterBtn()
}

final class LoginHomeViewController: UIViewController, LoginHomePresentable, LoginHomeViewControllable {

    weak var listener: LoginHomePresentableListener?
    
    private let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.text = "MENUAL에" + "\n" + "오신 것을 환영해요"
        return label
    }()
    
    private let titleID: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "아이디"
        return label
    }()
    
    private let titlePW: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "비밀번호"
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .gray
        textField.attributedPlaceholder = NSAttributedString(
            string: "아이디(이메일) 입력",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]
        )
        return textField
    }()
    
    private let pwTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.backgroundColor = .gray
        textField.attributedPlaceholder = NSAttributedString(
            string: "영문+숫자+특수문자 조합 8~15자",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]
        )
        return textField
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("로그인", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .yellow
        btn.addTarget(self, action: #selector(pressedLoginBtn), for: .touchUpInside)
        return btn
    }()
    
    private let findIDPWButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("ID/PW 찾기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(pressedFindIDPWBtn), for: .touchUpInside)
        return btn
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(pressedRegisterBtn), for: .touchUpInside)
        return btn
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RegisterID :: ViewDidLoad")
        setupViews()
    }
}

extension LoginHomeViewController {
    func setupViews() {
        title = "로그인"
        print("LoginHome :: setupViews")
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(titleID)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(titlePW)
        stackView.addArrangedSubview(pwTextField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(findIDPWButton)
        stackView.addArrangedSubview(registerButton)
        
        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    @objc
    func pressedLoginBtn() {
        
    }
    
    @objc
    func pressedFindIDPWBtn() {
        
    }
    
    @objc
    func pressedRegisterBtn() {
        listener?.pressedRegisterBtn()
    }
}


