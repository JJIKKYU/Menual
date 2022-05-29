//
//  TabsViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol TabsPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class TabsViewController: UIViewController, TabsPresentable, TabsViewControllable {

    weak var listener: TabsPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Tabs"
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewStep1 = TabsIconView(tabsIconStatus: .active, tabsIconStep: .step1).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewStep2 = TabsIconView(tabsIconStatus: .active, tabsIconStep: .step2).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewStep3 = TabsIconView(tabsIconStatus: .active, tabsIconStep: .step3).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewStep4 = TabsIconView(tabsIconStatus: .active, tabsIconStep: .step4).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewInactvieStep1 = TabsIconView(tabsIconStatus: .inactive, tabsIconStep: .step1).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewInactvieStep2 = TabsIconView(tabsIconStatus: .inactive, tabsIconStep: .step2).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewInactvieStep3 = TabsIconView(tabsIconStatus: .inactive, tabsIconStep: .step3).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let tabsIconViewInactvieStep4 = TabsIconView(tabsIconStatus: .inactive, tabsIconStep: .step4).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let flowlayout = UICollectionViewFlowLayout.init()
        $0.setCollectionViewLayout(flowlayout, animated: true)
        $0.backgroundColor = Colors.tint.main.v100
        $0.delegate = self
        $0.dataSource = self
        $0.register(TabsCell.self, forCellWithReuseIdentifier: "TabsCell")
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
        // self.view.addSubview(collectionView)
        self.view.addSubview(tabsIconViewStep1)
        self.view.addSubview(tabsIconViewStep2)
        self.view.addSubview(tabsIconViewStep3)
        self.view.addSubview(tabsIconViewStep4)
        
        self.view.addSubview(tabsIconViewInactvieStep1)
        self.view.addSubview(tabsIconViewInactvieStep2)
        self.view.addSubview(tabsIconViewInactvieStep3)
        self.view.addSubview(tabsIconViewInactvieStep4)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        tabsIconViewStep1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(120)
        }
        
        tabsIconViewStep2.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewStep1.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewStep1)
        }
        
        tabsIconViewStep3.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewStep2.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewStep1)
        }
        
        tabsIconViewStep4.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewStep3.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewStep1)
        }
        
        tabsIconViewInactvieStep1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewStep1.snp.bottom).offset(20)
        }
        
        tabsIconViewInactvieStep2.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewInactvieStep1.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewInactvieStep1)
        }
        
        tabsIconViewInactvieStep3.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewInactvieStep2.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewInactvieStep1)
        }
        
        tabsIconViewInactvieStep4.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconViewInactvieStep3.snp.trailing).offset(10)
            make.width.equalTo(15)
            make.height.equalTo(40)
            make.top.equalTo(tabsIconViewInactvieStep1)
        }
        
        /*
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.height.equalTo(56)
        }
        */
        
        /*
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
         */
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - UICollectionView Extension
extension TabsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabsCell", for: indexPath) as? TabsCell else { return UICollectionViewCell() }
        
        print("오잉?")
        return cell
    }
    
    
}
