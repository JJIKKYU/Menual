//
//  MetaDataViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import RIBs
import RxSwift
import Then
import SnapKit
import UIKit

protocol MetaDataPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class MetaDataViewController: UIViewController, MetaDataPresentable, MetaDataViewControllable {

    weak var listener: MetaDataPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "MetaData"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let metaDataWritingHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "WRITING"
    }
    
    private let metaDataWriting = MetaData(type: .writing).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let metaDataViewHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "VIEW"
    }
    
    private let metaDataView = MetaData(type: .view).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let metaDataImageHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "IMAGE"
    }
    
    private let metaDataImage = MetaData(type: .image).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let metaDataRewritingHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "REWRITING"
    }
    
    private let metaDataRewriting = MetaData(type: .rewriting).then {
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
        scrollView.addSubview(metaDataWritingHeader)
        scrollView.addSubview(metaDataWriting)
        
        scrollView.addSubview(metaDataViewHeader)
        scrollView.addSubview(metaDataView)
        
        scrollView.addSubview(metaDataImageHeader)
        scrollView.addSubview(metaDataImage)
        
        scrollView.addSubview(metaDataRewritingHeader)
        scrollView.addSubview(metaDataRewriting)
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
        
        metaDataWritingHeader.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalToSuperview().offset(66)
            make.height.equalTo(44)
        }
        
        metaDataWriting.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(metaDataWritingHeader.snp.bottom)
            make.height.equalTo(15)
        }
        
        metaDataViewHeader.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(metaDataWriting.snp.bottom).offset(45)
            make.height.equalTo(44)
        }
        
        metaDataView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(metaDataViewHeader.snp.bottom)
            make.height.equalTo(15)
        }
        
        metaDataImageHeader.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(metaDataView.snp.bottom).offset(45)
            make.height.equalTo(44)
        }
        
        metaDataImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(metaDataImageHeader.snp.bottom)
            make.height.equalTo(15)
        }
        
        metaDataRewritingHeader.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(metaDataImage.snp.bottom).offset(45)
            make.height.equalTo(44)
        }
        
        metaDataRewriting.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(metaDataRewritingHeader.snp.bottom)
            make.height.equalTo(15)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
