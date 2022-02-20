//
//  RegisterIDViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol RegisterIDPresentableListener: AnyObject {
    func pressedNextBtn()
}

final class RegisterIDViewController: UIViewController, RegisterIDPresentable, RegisterIDViewControllable {

    weak var listener: RegisterIDPresentableListener?
    
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
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "사용할 이메일을 입력해주세요."
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "ex) menual@mail.com",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]
        )
        return textField
    }()
    
    private let textFieldErrorLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.text = "오류 메시지 노출 영역입니다."
        return label
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("다음", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .yellow
        btn.addTarget(self, action: #selector(pressedNextBtn), for: .touchUpInside)
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

extension RegisterIDViewController {
    func setupViews() {
        title = "회원가입"
        print("RegisterID :: setupViews")
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(textFieldErrorLabel)
        stackView.addArrangedSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    @objc
    func pressedNextBtn() {
        listener?.pressedNextBtn()
    }
}
