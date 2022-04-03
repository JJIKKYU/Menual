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
import Then

protocol DiaryHomePresentableListener: AnyObject {
    func pressedSearchBtn()
    func pressedMyPageBtn()
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {

    weak var listener: DiaryHomePresentableListener?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let scrollView = UIScrollView().then {
        $0.backgroundColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset.StandardIcons.search.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedSearchBtn)
    }
    
    lazy var rightBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset.StandardIcons.profile.image
        $0.target = self
        $0.action = #selector(pressedMyPageBtn)
        $0.style = .done
    }
    
    let testView = MomentsRoundView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
   
    lazy var titleView = TitleView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.title_moments
        $0.rightTitle = "전체보기 >"
        $0.titleButton.addTarget(self, action: #selector(pressedMomentsTitleBtn), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(pressedMomentsMoreBtn), for: .touchUpInside)
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
        view.backgroundColor = .red
        print("DiaryHome!")
        setViews()
        
        title = MenualString.title_menual
    }
    
    func setViews() {
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(testView)
        scrollView.addSubview(titleView)
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
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
        
        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
    }
    
    @objc
    func pressedSearchBtn() {
        listener?.pressedSearchBtn()
    }
    
    @objc
    func pressedMyPageBtn() {
        listener?.pressedMyPageBtn()
    }
    
    @objc
    func pressedMomentsTitleBtn() {
        print("Moments Title Pressed!")
    }
    
    @objc
    func pressedMomentsMoreBtn() {
        print("Moments More Pressed!")
    }
}
