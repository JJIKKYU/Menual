//
//  EmptyViewViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol EmptyViewPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class EmptyViewViewController: UIViewController, EmptyViewPresentable, EmptyViewViewControllable {

    weak var listener: EmptyViewPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Empty"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let mainHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "MAIN"
    }
    
    let mainEmptyView = Empty().then {
        $0.screenType = .main
        $0.mainType = .main
    }
    
    let mainFilterEmptyView = Empty().then {
        $0.screenType = .main
        $0.mainType = .filter
    }
    
    let writingHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "WRITING"
    }
    
    let writingTempSaveEmptyView = Empty().then {
        $0.screenType = .writing
        $0.writingType = .temporarysave
    }
    
    let writingLockEmptyView = Empty().then {
        $0.screenType = .writing
        $0.writingType = .lock
    }
    
    let searchHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "SEARCH"
    }
    
    let searchEmptyView = Empty().then {
        $0.screenType = .search
        $0.searchType = .search
    }
    
    let searchResultEmptyView = Empty().then {
        $0.screenType = .search
        $0.searchType = .result
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
        print("Empty :: Empty!")
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
        scrollView.addSubview(mainHeader)
        scrollView.addSubview(mainEmptyView)
        scrollView.addSubview(mainFilterEmptyView)
        
        scrollView.addSubview(writingHeader)
        scrollView.addSubview(writingTempSaveEmptyView)
        scrollView.addSubview(writingLockEmptyView)
        
        scrollView.addSubview(searchHeader)
        scrollView.addSubview(searchEmptyView)
        scrollView.addSubview(searchResultEmptyView)
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
        
        mainHeader.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalToSuperview().offset(66)
            make.height.equalTo(44)
        }
        
        mainEmptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.top.equalTo(mainHeader.snp.bottom).offset(20)
        }
        
        mainFilterEmptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mainEmptyView.snp.bottom).offset(20)
            make.width.equalTo(188)
            make.height.equalTo(180)
        }
        
        writingHeader.snp.makeConstraints { make in
            make.top.equalTo(mainFilterEmptyView.snp.bottom).offset(40)
            make.width.leading.equalToSuperview()
            make.height.equalTo(44)
        }
        
        writingTempSaveEmptyView.snp.makeConstraints { make in
            make.top.equalTo(writingHeader.snp.bottom).offset(20)
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        writingLockEmptyView.snp.makeConstraints { make in
            make.top.equalTo(writingTempSaveEmptyView.snp.bottom).offset(20)
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        searchHeader.snp.makeConstraints { make in
            make.top.equalTo(writingLockEmptyView.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(44)
        }
        
        searchEmptyView.snp.makeConstraints { make in
            make.top.equalTo(searchHeader.snp.bottom).offset(20)
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        searchResultEmptyView.snp.makeConstraints { make in
            make.top.equalTo(searchEmptyView.snp.bottom).offset(20)
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func pressedBackBtn() {
        print("empty :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
