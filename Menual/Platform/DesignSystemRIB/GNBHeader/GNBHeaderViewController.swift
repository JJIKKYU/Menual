//
//  GNBHeaderViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol GNBHeaderPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class GNBHeaderViewController: UIViewController, GNBHeaderPresentable, GNBHeaderViewControllable {

    weak var listener: GNBHeaderPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "GNB Header"
    }
    
    lazy var gnbHeaderMain = MenualNaviView(type: .main).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var gnbHeaderMenualDetailUnactive = MenualNaviView(type: .menualDetail).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = false
    }
    
    lazy var gnbHeaderMenualDetailActive = MenualNaviView(type: .menualDetail).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = true
    }
    
    lazy var gnbHeaderWriteUnactive = MenualNaviView(type: .write).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = false
    }
    
    lazy var gnbHeaderWriteActive = MenualNaviView(type: .write).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = true
    }
    
    lazy var gnbHeaderEditUnactive = MenualNaviView(type: .edit).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = false
    }
    
    lazy var gnbHeaderEditActive = MenualNaviView(type: .edit).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1IsActive = true
    }
    
    lazy var gnbHeaderTemporarySave = MenualNaviView(type: .temporarySave).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var gnbHeaderMoments = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var gnbHeaderSearch = MenualNaviView(type: .search).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var gnbHeaderMypage = MenualNaviView(type: .myPage).then {
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
        view.backgroundColor = Colors.background.black
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
        self.scrollView.addSubview(gnbHeaderMain)
        self.scrollView.addSubview(gnbHeaderMenualDetailUnactive)
        self.scrollView.addSubview(gnbHeaderMenualDetailActive)
        self.scrollView.addSubview(gnbHeaderWriteUnactive)
        self.scrollView.addSubview(gnbHeaderWriteActive)
        self.scrollView.addSubview(gnbHeaderEditUnactive)
        self.scrollView.addSubview(gnbHeaderEditActive)
        self.scrollView.addSubview(gnbHeaderTemporarySave)
        self.scrollView.addSubview(gnbHeaderMoments)
        self.scrollView.addSubview(gnbHeaderSearch)
        self.scrollView.addSubview(gnbHeaderMypage)
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
        
        gnbHeaderMain.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(66)
            make.height.equalTo(44)
        }
        
        gnbHeaderMenualDetailUnactive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderMain.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderMenualDetailActive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderMenualDetailUnactive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderWriteUnactive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderMenualDetailActive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderWriteActive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderWriteUnactive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderEditUnactive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderWriteActive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderEditActive.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderEditUnactive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderTemporarySave.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderEditActive.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderMoments.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderTemporarySave.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderSearch.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderMoments.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        gnbHeaderMypage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(gnbHeaderSearch.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
