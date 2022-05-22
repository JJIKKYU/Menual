//
//  MomentsViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import Then

protocol MomentsPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class MomentsViewController: UIViewController, MomentsPresentable, MomentsViewControllable {

    weak var listener: MomentsPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Moments"
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
        view.backgroundColor = Colors.background.black
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let momentsTagShort = MomentsTag().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "TEXT AREA"
    }
    
    private let momentsTagLong = MomentsTag().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "TEXT AREA TEXT AREA"
    }
    
    private let momentsTagLongLong = MomentsTag().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "TEXT AREA TEXT AREA TEXT AREA TEXT AREA"
    }
    
    private let momentsText = MomentsText().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tagTitle = "TEXT AREA"
        $0.momentsTitle = "타이틀은 최대 20자를 작성할 수 있습니다. 그 이상일경우는 어떻게 될까요?"
    }
    
    private let moments = Moments().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tagTitle = "TEXT AREA"
        $0.momentsTitle = "타이틀은 최대 20자를 작성할 수 있습니다. 그 이상일경우는 어떻게 될까요?"
    }
    
    private let momentsShort = Moments().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tagTitle = "TEXT AREA"
        $0.momentsTitle = "타이틀은 최대 20자를 작성할 수 있습니다. 그 이상일경우는 어떻게 될까요?"
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(momentsTagShort)
        self.scrollView.addSubview(momentsTagLong)
        self.scrollView.addSubview(momentsTagLongLong)
        self.scrollView.addSubview(momentsText)
        self.scrollView.addSubview(momentsShort)
        self.scrollView.addSubview(moments)
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
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        momentsTagShort.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(66)
        }
        
        momentsTagLong.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(momentsTagShort.snp.bottom).offset(20)
        }
        
        momentsTagLongLong.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(momentsTagLong.snp.bottom).offset(20)
        }
        
        momentsText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(180)
            make.height.equalTo(79)
            make.top.equalTo(momentsTagLongLong.snp.bottom).offset(20)
        }
        
        momentsShort.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(335)
            make.height.equalTo(120)
            make.top.equalTo(momentsText.snp.bottom).offset(20)
        }
        
        moments.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(momentsShort.snp.bottom).offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
