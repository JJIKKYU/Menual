//
//  ProfileOpensourceViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/27.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit
import DesignSystem

public protocol ProfileOpensourcePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class ProfileOpensourceViewController: UIViewController, ProfileOpensourcePresentable, ProfileOpensourceViewControllable {

    weak var listener: ProfileOpensourcePresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "오픈 소스 라이브러리"
    }
    
    lazy var textView = UITextView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g200
        $0.isScrollEnabled = true
        $0.isEditable = false
        $0.backgroundColor = .clear
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
        setTextView()
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
        self.view.addSubview(textView)
        
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func setTextView() {
        let bodyString = """
                         RIBs
                         https://github.com/uber/RIBs
                         Apache-2.0 license
                         
                         RXSwift
                         https://github.com/ReactiveX/RxSwift
                         MIT
                         
                         RealmSwift
                         https://github.com/realm/realm-swift
                         Apache-2.0 license
                         
                         RxViewController
                         https://github.com/devxoul/RxViewController
                         MIT
                         
                         Then
                         https://github.com/devxoul/Then
                         MIT
                         
                         TOCropViewController
                         https://github.com/TimOliver/TOCropViewController
                         MIT
                         """
        textView.text = bodyString
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
