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

protocol ProfilePasswordPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class ProfilePasswordViewController: UIViewController, ProfilePasswordPresentable, ProfilePasswordViewControllable {

    weak var listener: ProfilePasswordPresentableListener?
    
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        numberPad.delegate = nil
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
    }
}
