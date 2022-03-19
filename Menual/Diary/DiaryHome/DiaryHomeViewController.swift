//
//  DiaryHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol DiaryHomePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {

    weak var listener: DiaryHomePresentableListener?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "123"
        return label
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var leftBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: Asset.search.image,
                                   style: .done,
                                   target: self,
                                   action: #selector(pressedSearchBtn))
        return item
    }()
    
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: Asset.profile.image,
                                   style: .done,
                                   target: self,
                                   action: #selector(pressedMyPageBtn))
        return item
    }()
    
    let testView: MomentsRoundView = {
        let view = MomentsRoundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        view.backgroundColor = .red
        print("DiaryHome!")
        setViews()
        
        title = "MENUAL"
    }
    
    func setViews() {
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(testView)
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1000)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        testView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(300)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(200)
        }
    }
    
    @objc
    func pressedSearchBtn() {
        print("pressedSearchBtn!")
    }
    
    @objc
    func pressedMyPageBtn() {
        print("pressedMyPageBtn!")
    }
}
