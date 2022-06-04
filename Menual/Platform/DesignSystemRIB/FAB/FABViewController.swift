//
//  FABViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol FABPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class FABViewController: UIViewController, FABPresentable, FABViewControllable {

    weak var listener: FABPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "FAB"
    }
    
    lazy var fabDefaultPrimary = FAB(fabType: .primary, fabStatus: .default_).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var fabPressedPrimary = FAB(fabType: .primary, fabStatus: .pressed).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var fabDefaultSecondary = FAB(fabType: .secondary, fabStatus: .default_).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var fabPressedSecondary = FAB(fabType: .secondary, fabStatus: .pressed).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var scrollView = UIScrollView().then {
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
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(fabDefaultPrimary)
        self.scrollView.addSubview(fabPressedPrimary)
        self.scrollView.addSubview(fabDefaultSecondary)
        self.scrollView.addSubview(fabPressedSecondary)
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
        
        fabDefaultPrimary.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(60)
            make.width.height.equalTo(56)
        }
        
        fabPressedPrimary.snp.makeConstraints { make in
            make.leading.equalTo(fabDefaultPrimary.snp.trailing).offset(20)
            make.top.equalTo(fabDefaultPrimary)
            make.width.height.equalTo(56)
        }
        
        fabDefaultSecondary.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(fabDefaultPrimary.snp.bottom).offset(20)
            make.width.height.equalTo(56)
        }
        
        fabPressedSecondary.snp.makeConstraints { make in
            make.leading.equalTo(fabDefaultSecondary.snp.trailing).offset(20)
            make.top.equalTo(fabDefaultSecondary)
            make.width.height.equalTo(56)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
