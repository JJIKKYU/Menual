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
    
    func pressedBackBtn()
    func searchTest(keyword: String)
}

final class DiarySearchViewController: UIViewController, DiarySearchPresentable, DiarySearchViewControllable {

    weak var listener: DiarySearchPresentableListener?
    var disposeBag = DisposeBag()
    
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
        $0.register(DiarySearchCell.self, forCellReuseIdentifier: "SearchCell")
        $0.estimatedRowHeight = 87
        $0.rowHeight = 87
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
                self.listener?.searchTest(keyword: keyword)
            })
            .disposed(by: disposeBag)
    }
    
    func setViews() {
        
        self.view.addSubview(tableView)
        self.view.addSubview(naviView)
        self.view.addSubview(searchTextField)
        self.view.bringSubviewToFront(naviView)
        self.tableView.addSubview(searchView)
        tableView.tableHeaderView = searchView
        searchView.sizeToFit()
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(50)
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
    
    func reloadSearchTableView() {
        tableView.reloadData()
    }
}


extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.searchResultList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? DiarySearchCell else { return UITableViewCell() }
        
        let index = indexPath.row
        guard let model = listener?.searchResultList[safe: index] else {
            return UITableViewCell()
        }

        cell.title = model.title
        cell.desc = model.description
        cell.page = "0"
        cell.createdAt = model.createdAt.description(with: .autoupdatingCurrent)
        
        return cell
    }
}

extension DiarySearchViewController: UISearchBarDelegate {
    
}

extension DiarySearchViewController: UITextFieldDelegate {
    
}
