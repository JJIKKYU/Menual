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
    var searchResultList: [DiaryModel] { get }
    var recentSearchResultList: [SearchModel] { get }
    
    func pressedBackBtn()
    func searchTest(keyword: String)
    func searchDataTest(keyword: String)
}

final class DiarySearchViewController: UIViewController, DiarySearchPresentable, DiarySearchViewControllable {

    weak var listener: DiarySearchPresentableListener?
    var disposeBag = DisposeBag()
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = MenualString.title_search
    }
    
    var recentSearchListView = UIView().then {
        $0.backgroundColor = .gray
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var searchBtn = UIButton().then {
        $0.setImage(Asset._24px.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.addTarget(self, action: #selector(pressedSearchBtn), for: .touchUpInside)
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    lazy var recentSearchTableView = UITableView().then {
        $0.isHidden = false
        $0.delegate = self
        $0.dataSource = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .brown
        $0.register(RecentSearchCell.self, forCellReuseIdentifier: "RecentSearchCell")
    }
    
    lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
        $0.register(DiarySearchCell.self, forCellReuseIdentifier: "SearchCell")
        $0.estimatedRowHeight = 87
        $0.rowHeight = 87
        $0.isHidden = true
    }
    
    lazy var searchTextField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.backgroundColor = .gray
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
        bind()
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    func bind() {
        searchTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                if keyword.count == 0 {
                    self.tableView.isHidden = true
                    self.recentSearchListView.isHidden = false
                    self.recentSearchTableView.isHidden = false
                } else {
                    self.tableView.isHidden = false
                    self.recentSearchListView.isHidden = true
                    self.recentSearchTableView.isHidden = true
                }
                
                self.listener?.searchTest(keyword: keyword)
            })
            .disposed(by: disposeBag)
    }
    
    func setViews() {
        
        self.view.addSubview(tableView)
        self.view.addSubview(naviView)
        self.view.addSubview(searchTextField)
        self.view.addSubview(searchBtn)
        self.view.bringSubviewToFront(naviView)
        self.view.addSubview(recentSearchTableView)
        self.tableView.addSubview(searchView)
        tableView.tableHeaderView = searchView
        searchView.sizeToFit()
        
        recentSearchTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(searchTextField.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(200)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(50)
        }
        
        searchBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(100)
            make.width.height.equalTo(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(30)
            make.leading.trailing.bottom.equalToSuperview()
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
    
    @objc
    func pressedSearchBtn() {
        print("pressedSearchBtn")
        guard let text = searchTextField.text else { return }
        listener?.searchDataTest(keyword: text)
    }
    
    func reloadSearchTableView() {
        tableView.reloadData()
        recentSearchTableView.reloadData()
    }
}


extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return listener?.searchResultList.count ?? 0
        } else if tableView == self.recentSearchTableView {
            return listener?.recentSearchResultList.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if tableView == self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? DiarySearchCell else { return UITableViewCell() }
            
            guard let model = listener?.searchResultList[safe: index] else {
                return UITableViewCell()
            }

            cell.keyword = searchTextField.text
            cell.title = model.title
            cell.desc = model.description
            cell.page = "0"
            cell.createdAt = model.createdAt.description(with: .autoupdatingCurrent)
            
            return cell
        } else if tableView == self.recentSearchTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell") as? RecentSearchCell else { return UITableViewCell() }
            
            guard let model = listener?.recentSearchResultList[safe: index] else {
                return UITableViewCell()
            }
            
            cell.keyword = model.keyword
            cell.createdAt = model.createdAt.description
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension DiarySearchViewController: UISearchBarDelegate {
    
}

extension DiarySearchViewController: UITextFieldDelegate {
    
}
