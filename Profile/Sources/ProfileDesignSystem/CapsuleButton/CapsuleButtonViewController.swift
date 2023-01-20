//
//  CapsuleButtonViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import Then
import DesignSystem

protocol CapsuleButtonPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class CapsuleButtonViewController: UIViewController, CapsuleButtonPresentable, CapsuleButtonViewControllable {

    weak var listener: CapsuleButtonPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Capsule Button"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let capsuleButtonDefaultTextOnly = CapsuleButton(frame: CGRect.zero, includeType: .textOnly).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
    }
    
    private let capsuleButtonDefaultIconText = CapsuleButton(frame: CGRect.zero, includeType: .iconText).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
        $0.image = Asset._16px.Circle.front.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g500
    }
    
    private let capsuleButtonPressedTextOnly = CapsuleButton(frame: CGRect.zero, includeType: .textOnly).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
        $0.btnSelected = true
    }
    
    private let capsuleButtonPressedIconText = CapsuleButton(frame: CGRect.zero, includeType: .iconText).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
        $0.image = Asset._16px.Circle.front.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g500
        $0.btnSelected = true
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
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(capsuleButtonDefaultTextOnly)
        self.scrollView.addSubview(capsuleButtonDefaultIconText)
        self.scrollView.addSubview(capsuleButtonPressedTextOnly)
        self.scrollView.addSubview(capsuleButtonPressedIconText)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        capsuleButtonDefaultTextOnly.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(66)
            make.width.equalTo(58)
            make.height.equalTo(27)
        }
        
        capsuleButtonDefaultIconText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(capsuleButtonDefaultTextOnly.snp.bottom).offset(20)
            make.width.equalTo(78)
            make.height.equalTo(28)
        }
        
        capsuleButtonPressedTextOnly.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(capsuleButtonDefaultIconText.snp.bottom).offset(20)
            make.width.equalTo(58)
            make.height.equalTo(27)
        }
        
        capsuleButtonPressedIconText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(capsuleButtonPressedTextOnly.snp.bottom).offset(20)
            make.width.equalTo(78)
            make.height.equalTo(28)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
