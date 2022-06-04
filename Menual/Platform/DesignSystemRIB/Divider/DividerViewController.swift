//
//  DividerViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol DividerPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class DividerViewController: UIViewController, DividerPresentable, DividerViewControllable {

    weak var listener: DividerPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Divider"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let divider1px = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let divider2px = Divider(type: ._2px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let dividerYear = Divider(type: .year).then {
        $0.dateTitle = "2099"
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
        scrollView.addSubview(divider1px)
        scrollView.addSubview(divider2px)
        scrollView.addSubview(dividerYear)
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
        
        divider1px.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(1)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(66)
        }
        
        divider2px.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(2)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(divider1px.snp.bottom).offset(20)
        }
        
        dividerYear.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(24)
            make.height.equalTo(56)
            make.top.equalTo(divider2px.snp.bottom).offset(20)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
