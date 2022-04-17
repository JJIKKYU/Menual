//
//  DiarySearchViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import RxSwift
import Then
import SnapKit
import UIKit

protocol DiarySearchPresentableListener: AnyObject {
    func pressedBackBtn()
}

final class DiarySearchViewController: UIViewController, DiarySearchPresentable, DiarySearchViewControllable {

    weak var listener: DiarySearchPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = MenualString.title_search
    }
    
    lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
    }
    
    var searchView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
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
        view.backgroundColor = .black
        print("DiarySearch!!")
        setViews()
        
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    func setViews() {
        
        self.view.addSubview(tableView)
        self.view.addSubview(naviView)
        self.view.bringSubviewToFront(naviView)
        self.tableView.addSubview(searchView)
        tableView.tableHeaderView = searchView
        searchView.sizeToFit()
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn()
    }
}


extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension DiarySearchViewController: UISearchBarDelegate {
    
}
