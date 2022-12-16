//
//  ProfilePasswordViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit
import RxRelay

protocol ProfilePasswordPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    var prevPassword: [Int] { get set }
    var currentPassword: [Int] { get set }
    func setPassword(passwordArr: [Int])
    
    var userTypedPasswordRelay: BehaviorRelay<[Int]> { get }
    var userTypedPasswordCurrectRelay: BehaviorRelay<Bool?> { get }
    var isMainScreen: BehaviorRelay<Bool> { get }
    var isPasswordChange: Bool { get }
    var isPaswwordDisabled: Bool { get }
    func checkPassword(passwordArr: [Int]) -> Bool
}

final class ProfilePasswordViewController: UIViewController, ProfilePasswordPresentable, ProfilePasswordViewControllable {

    weak var listener: ProfilePasswordPresentableListener?
    private let disposeBag = DisposeBag()
    
    lazy var naviView = MenualNaviView(type: .myPageCancel).then {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.rightButton1.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    private lazy var numberPad = NumberPad().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
    }
    
    private lazy var passwordView = PasswordView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
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
        view.backgroundColor = Colors.background
        setViews()
        bind()

        if listener?.isPasswordChange ?? false {
            passwordView.type = .check
            passwordView.screenType = .change
        } else if listener?.isPaswwordDisabled ?? false {
            passwordView.type = .check
            passwordView.screenType = .change
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        numberPad.delegate = nil
    }
    
    func bind() {
        listener?.isMainScreen
            .subscribe(onNext: { [weak self] isMainScreen in
                guard let self = self else { return }
                if isMainScreen {
                    self.passwordView.screenType = .main
                    self.naviView.rightButton1.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        listener?.userTypedPasswordCurrectRelay
            .subscribe(onNext: { [weak self] isCurrect in
                guard let self = self else { return }
                guard let isCurrect = isCurrect else { return }

                switch isCurrect {
                case true:
                    return

                case false:
                    self.passwordView.numberArr = []
                    self.passwordView.type = .error
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setViews() {
        view.addSubview(naviView)
        self.view.addSubview(numberPad)
        self.view.addSubview(passwordView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(56)
            make.centerX.equalToSuperview()
            make.width.equalTo(228)
            make.height.equalTo(206)
        }
        
        numberPad.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(48)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - IBAction
extension ProfilePasswordViewController {
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

extension ProfilePasswordViewController: NumberPadDelegate {
    func deleteNumber() {
        if passwordView.numberArr.isEmpty { return }
        passwordView.numberArr.removeLast()
    }
    
    func selectNumber(number: Int) {
        if passwordView.numberArr.count == 4 { return }
        passwordView.numberArr.append(number)
        
        guard let isMainScreen = listener?.isMainScreen.value,
              let isPasswordChange = listener?.isPasswordChange,
              let isPaswwordDisabled = listener?.isPaswwordDisabled
        else { return }
        print("ProfilePassword :: isMainScreen = \(isMainScreen), isPasswordChange = \(isPasswordChange)")

        switch isMainScreen {
        case true:
            if passwordView.type == .error {
                passwordView.type = .first
            }

            if passwordView.numberArr.count == 4 {
                listener?.userTypedPasswordRelay.accept(passwordView.numberArr)
            }

        case false:
            print("ProfilePassword :: isMainScreen = \(isMainScreen)")
            
            // 패스워드 변경
            switch isPasswordChange {
            case true:
                if passwordView.type == .error {
                    passwordView.type = .check
                }
                
                // 4번째 입력했을 경우
                if passwordView.numberArr.count == 4 && passwordView.type == .check {
                    print("ProfilePassword :: 입력한 비밀번호 = \(passwordView.numberArr)")
                    guard let isCorrectPassword: Bool = listener?.checkPassword(passwordArr: passwordView.numberArr) else { return }
                    
                    switch isCorrectPassword {
                    case true:
                        passwordView.numberArr = []
                        passwordView.type = .first
                    case false:
                        passwordView.numberArr = []
                        passwordView.type = .error
                    }
                } else if passwordView.numberArr.count == 4 && passwordView.type == .first {
                    print("ProfilePassword :: 입력한 비밀번호 = \(passwordView.numberArr)")
                    listener?.prevPassword = passwordView.numberArr
                    passwordView.numberArr = []
                    passwordView.type = .second
                }
                else if passwordView.numberArr.count == 4 && passwordView.type == .second {
                    guard let prevPassword = listener?.prevPassword else { return }
                    let currentPassword = passwordView.numberArr
                    
                    for index in 0..<4 {
                        if prevPassword[index] != currentPassword[index] {
                            passwordView.numberArr = []
                            passwordView.type = .error
                            print("ProfilePassword :: 비밀번호가 올바르지 않습니다")
                            return
                        }
                    }

                    print("ProfilePassword :: 비밀번호가 올바르게 입력 되었습니다.")
                    listener?.setPassword(passwordArr: currentPassword)
                }

            case false:
                switch isPaswwordDisabled {
                // 비밀번호 비활성화
                case true:
                    if passwordView.type == .error {
                        passwordView.type = .first
                    }

                    // 4번째 입력했을 경우
                    if passwordView.numberArr.count == 4 && passwordView.type == .check {
                        guard let isCorrectPassword: Bool = listener?.checkPassword(passwordArr: passwordView.numberArr) else { return }
                        
                        switch isCorrectPassword {
                        case true:
                            listener?.setPassword(passwordArr: passwordView.numberArr)
                        case false:
                            passwordView.numberArr = []
                            passwordView.type = .error
                        }
                    }

                // 비밀번호 최초설정
                case false:
                    if passwordView.type == .error {
                        passwordView.type = .first
                    }

                    // 4번째 입력했을 경우
                    if passwordView.numberArr.count == 4 && passwordView.type == .first {
                        print("ProfilePassword :: 입력한 비밀번호 = \(passwordView.numberArr)")
                        listener?.prevPassword = passwordView.numberArr
                        passwordView.numberArr = []
                        passwordView.type = .second
                    } else if passwordView.numberArr.count == 4 && passwordView.type == .second {
                        guard let prevPassword = listener?.prevPassword else { return }
                        let currentPassword = passwordView.numberArr
                        
                        for index in 0..<4 {
                            if prevPassword[index] != currentPassword[index] {
                                passwordView.numberArr = []
                                passwordView.type = .error
                                print("ProfilePassword :: 비밀번호가 올바르지 않습니다")
                                return
                            }
                        }

                        print("ProfilePassword :: 비밀번호가 올바르게 입력 되었습니다.")
                        listener?.setPassword(passwordArr: currentPassword)
                    }
                }
                

            }
        }
    }
}
