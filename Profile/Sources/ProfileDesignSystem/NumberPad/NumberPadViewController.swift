//
//  NumberPadViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit
import MenualUtil
import DesignSystem

protocol NumberPadPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class NumberPadViewController: UIViewController, NumberPadPresentable, NumberPadViewControllable {

    weak var listener: NumberPadPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "NumberPad"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(numberPad)
        self.view.addSubview(passwordView)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        numberPad.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(352)
            make.bottom.equalToSuperview()
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(228)
            make.height.equalTo(210)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - NumberPadDeleaget
extension NumberPadViewController: NumberPadDelegate {
    func deleteNumber() {
        print("NumberPad :: deleteNumber!")
        if passwordView.numberArr.isEmpty { return }
        passwordView.numberArr.removeLast()
    }
    
    func selectNumber(number: Int) {
        print("NumberPad :: selectNumber! = \(number)")
        if passwordView.numberArr.count == 4 { return }
        passwordView.numberArr.append(number)
    }
}
