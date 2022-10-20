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
import RxRelay

protocol DiarySearchPresentableListener: AnyObject {
    var recentSearchResultsRelay: BehaviorRelay<[DiarySearchModel]> { get }
    var searchResultsRelay: BehaviorRelay<[DiaryModel]> { get }
    
    func pressedBackBtn(isOnlyDetach: Bool)
    func searchTest(keyword: String)
    func searchDataTest(keyword: String)
    func fetchRecentSearchList()
    func pressedSearchCell(diaryModel: DiaryModel)
}

final class DiarySearchViewController: UIViewController, DiarySearchPresentable, DiarySearchViewControllable {

    weak var listener: DiarySearchPresentableListener?
    var disposeBag = DisposeBag()
    
    var menualCount: Int = 0
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = MenualString.title_search
    }
    
    lazy var recentSearchTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.isHidden = false
        $0.delegate = self
        $0.dataSource = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.register(RecentSearchCell.self, forCellReuseIdentifier: "RecentSearchCell")
        $0.tag = 1
    }
    
    lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.register(RecentSearchCell.self, forCellReuseIdentifier: "RecentSearchCell")

        $0.estimatedRowHeight = 72
        $0.rowHeight = 72
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .zero
        $0.contentInsetAdjustmentBehavior = .never
        $0.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    lazy var searchTextField = DiarySearchView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textField.delegate = self
        $0.deleteBtn.addTarget(self, action: #selector(pressedTextFieldDeleteBtn), for: .touchUpInside)
    }
    
    /*
    private let searchMenualCountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_4)
        $0.textColor = .white
        $0.text = "총 N개의 메뉴얼"
    }
     
    
    private let searchView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
    }
    
    private let searchViewDivider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
     */
    
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
        bind()

        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        
        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func bind() {
        searchTextField.textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                
                 // self.listener?.searchDataTest(keyword: keyword)
                 self.listener?.searchTest(keyword: keyword)
//                self.listener?.fetchRecentSearchList()
            })
            .disposed(by: disposeBag)
        
        listener?.searchResultsRelay
            .subscribe(onNext: { [weak self] results in
                guard let self = self else { return }
                let count = results.count
                self.menualCount = count
                self.tableView.reloadData()
                self.recentSearchTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        listener?.recentSearchResultsRelay
            .subscribe(onNext: { [weak self] results in
                guard let self = self else { return }
                print("Search :: recentSearchResultsRelay! = \(results)")
                self.recentSearchTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func setViews() {
        
        self.view.addSubview(tableView)
        self.view.addSubview(naviView)
        self.view.addSubview(searchTextField)
        // self.view.addSubview(recentSearchTableView)
        self.view.bringSubviewToFront(naviView)
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
//        recentSearchTableView.snp.makeConstraints { make in
//            make.top.equalTo(searchTextField.snp.bottom).offset(24)
//            make.leading.trailing.bottom.equalToSuperview()
//        }
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
    }

    
    func reloadSearchTableView() {
        tableView.reloadData()
        // recentSearchTableView.reloadData()
    }
}

// MARK: - @IBACtion
extension DiarySearchViewController {
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    // RecentSearchCell의 Delete Btn이 클릭되었을때
    @objc
    func pressedRecentSearchCellDeleteBtn() {
        print("pressedDeleteBtn!")
    }
    
    @objc
    func pressedTextFieldDeleteBtn() {
        self.searchTextField.textField.text = ""
        self.listener?.searchTest(keyword: "")
    }
}

// MARK: - UITableView
extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if menualCount == 0 {
                return .leastNormalMagnitude
            }
            return 34
        case 1:
            return 34
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            let headerView = ListHeader(type: .search, rightIconType: .none)
            let divider = Divider(type: ._2px)
            headerView.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.top.equalTo(headerView.snp.top).offset(32)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(2)
            }
            
            if menualCount == 0 {
                let view = UIView()
                view.backgroundColor = .blue
                return view
            }
            headerView.title = "TOTAL \(menualCount)"
            
            
            return headerView
            
        case 1:
            let headerView = ListHeader(type: .search, rightIconType: .searchDelete)
            let divider = Divider(type: ._2px)
            headerView.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.top.equalTo(headerView.snp.top).offset(32)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(2)
            }
            
            headerView.title = "RECENT"
            return headerView
            
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return listener?.searchResultsRelay.value.count ?? 0
            
        case 1:
            print("Search :: cellCount = \(listener?.recentSearchResultsRelay.value.count ?? 0)")
            return listener?.recentSearchResultsRelay.value.count ?? 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Search :: cell IndexPath = \(indexPath)")
        let index = indexPath.row
        print("Search :: \(tableView.tag)")
        // 검색 결과 TableView
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }
            
            guard let model = listener?.searchResultsRelay.value[safe: index],
                  let searchKeyword = self.searchTextField.textField.text else {
                return UITableViewCell()
            }
            
            cell.uuid = model.uuid
            if model.isHide {
                cell.listType = .hide
            } else {
                // TODO: - 이미지가 있을 경우 이미지까지
                cell.listType = .text
            }
            cell.title = model.title
            cell.dateAndTime = model.createdAt.toString()

            let page = "P.\(model.pageNum)"
            var replies = ""
            if model.replies.count != 0 {
                replies = "- \(model.replies.count)"
            }

            cell.searchKeyword = searchKeyword
            cell.pageAndReview = page + replies
            
            return cell
        }
        // 최근 검색 키워드 TableView
        else if indexPath.section == 1 {
            print("Search :: cell!")
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell") as? RecentSearchCell else { return UITableViewCell() }

            guard let model = listener?.recentSearchResultsRelay.value[safe: index],
                  let diary = model.diary else {
                print("Search :: 여기서 팅귀나?")
                return UITableViewCell()
            }
            
            print("Search :: cell! - 2")

            cell.keyword = diary.title
            cell.createdAt = model.createdAt.toStringWithHourMin()
            cell.deleteBtn.addTarget(self, action: #selector(pressedRecentSearchCellDeleteBtn), for: .touchUpInside)

            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 검색 결과 TableView
        if tableView == self.tableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
            print("선택했습니다! - \(cell.uuid)")
            
            let index = indexPath.row
            guard let model = listener?.searchResultsRelay.value[safe: index] else {
                return
            }
            
            print("이거 = \(model.uuid), \(cell.uuid)")
            
            listener?.pressedSearchCell(diaryModel: model)
        }
    }
}

extension DiarySearchViewController: UISearchBarDelegate {
    
}

extension DiarySearchViewController: UITextFieldDelegate {
    
}

// MARK: - Keyboard Extension
extension DiarySearchViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        print("keyboardWillShow! - \(keyboardHeight)")
        tableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide!")
        tableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
}
