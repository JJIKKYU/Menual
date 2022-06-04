//
//  BoxButtonViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift
import SnapKit
import UIKit

protocol BoxButtonPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class BoxButtonViewController: UIViewController, BoxButtonPresentable, BoxButtonViewControllable {

    weak var listener: BoxButtonPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Box Button"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    private let activeBoxBtnXLarge = BoxButton(frame: CGRect.zero, btnStatus: .active, btnSize: .xLarge).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
        $0.btnSelected = false
    }
    
    private let activeBoxBtnlarge = BoxButton(frame: CGRect.zero, btnStatus: .active, btnSize: .large).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
        $0.btnSelected = false
    }
    
    private let inactiveBoxBtnXLarge = BoxButton(frame: CGRect.zero, btnStatus: .inactive, btnSize: .xLarge).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
    }
    
    private let inactiveBoxBtnLarge = BoxButton(frame: CGRect.zero, btnStatus: .inactive, btnSize: .large).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
    }
    
    private let pressedBoxBtnXLarge = BoxButton(frame: CGRect.zero, btnStatus: .pressed, btnSize: .xLarge).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
        $0.btnSelected = true
    }
    
    private let pressedBoxBtnLarge = BoxButton(frame: CGRect.zero, btnStatus: .pressed, btnSize: .large).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트를 입력해주세요"
        $0.btnSelected = true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(activeBoxBtnXLarge)
        self.scrollView.addSubview(activeBoxBtnlarge)
        self.scrollView.addSubview(inactiveBoxBtnXLarge)
        self.scrollView.addSubview(inactiveBoxBtnLarge)
        self.scrollView.addSubview(pressedBoxBtnXLarge)
        self.scrollView.addSubview(pressedBoxBtnLarge)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        activeBoxBtnXLarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalToSuperview().offset(64)
        }
        
        activeBoxBtnlarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.top.equalTo(activeBoxBtnXLarge.snp.bottom).offset(20)
        }
        
        inactiveBoxBtnXLarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(activeBoxBtnlarge.snp.bottom).offset(20)
        }
        
        inactiveBoxBtnLarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.top.equalTo(inactiveBoxBtnXLarge.snp.bottom).offset(20)
        }
        
        pressedBoxBtnXLarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(inactiveBoxBtnLarge.snp.bottom).offset(20)
        }
        
        pressedBoxBtnLarge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.top.equalTo(pressedBoxBtnXLarge.snp.bottom).offset(20)
        }
    }
    
    @objc
    func pressedBackBtn() {
         listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
