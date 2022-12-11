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
import RealmSwift

protocol DiarySearchPresentableListener: AnyObject {
    var searchResultsRelay: BehaviorRelay<[DiaryModelRealm]> { get }
    var recentSearchModel: List<DiarySearchModelRealm>? { get }
    
    func pressedBackBtn(isOnlyDetach: Bool)
    func search(keyword: String)
    func pressedSearchCell(diaryModel: DiaryModelRealm)
    func pressedRecentSearchCell(diaryModel: DiaryModelRealm)
    func deleteAllRecentSearchData()
    func deleteRecentSearchData(uuid: String)
}

final class DiarySearchViewController: UIViewController, DiarySearchViewControllable {
    
    public enum DiarySearchSectionType: Int {
        case search = 0
        case recentSearch = 1
    }

    weak var listener: DiarySearchPresentableListener?
    var disposeBag = DisposeBag()
    
    var menualCount: Int = 0
    var searchText: String = ""
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = MenualString.title_search
    }
    
    lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")

        $0.estimatedRowHeight = 72
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = .zero
        $0.contentInsetAdjustmentBehavior = .never
        $0.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private let recentSearchEmptyView = Empty().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.screenType = .search
        $0.searchType = .search
        $0.isHidden = true
    }
    
    private let searchEmptyView = Empty().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.screenType = .search
        $0.searchType = .result
    }
    
    lazy var searchTextField = DiarySearchView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textField.delegate = self
        $0.deleteBtn.addTarget(self, action: #selector(pressedTextFieldDeleteBtn), for: .touchUpInside)
    }
    
    private lazy var headerView = ListHeader(type: .search, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "TOTAL \(menualCount)"
    }
    let divider = Divider(type: ._2px)

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.textField.becomeFirstResponder()
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
                
                self.listener?.search(keyword: keyword)
                self.searchText = keyword
            })
            .disposed(by: disposeBag)
        
        listener?.searchResultsRelay
            .subscribe(onNext: { [weak self] results in
                guard let self = self else { return }
                let count = results.count
                self.menualCount = count
                self.headerView.title = "TOTAL \(count)"
                if count == 0 {
                    self.searchEmptyView.isHidden = false
                } else {
                    self.searchEmptyView.isHidden = true
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func setViews() {
        
        self.view.addSubview(tableView)
        self.view.addSubview(naviView)
        self.view.addSubview(searchTextField)
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
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

// MARK: - DiarySearchPresentable
extension DiarySearchViewController: DiarySearchPresentable {
    func reloadSearchTableView() {
        // 최근검색결과 Section
        if let count = listener?.recentSearchModel?.count {
            if count == 0 {
                self.recentSearchEmptyView.isHidden = false
            } else {
                self.recentSearchEmptyView.isHidden = true
            }
        }
        
        tableView.reloadData()
    }
    
    func updateRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.reloadRows(at: indexPaths, with: .automatic)
        reloadSearchTableView()
    }
    
    func insertRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        tableView.beginUpdates()
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        reloadSearchTableView()
    }
    
    func deleteRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        tableView.beginUpdates()
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.deleteRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        reloadSearchTableView()
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
        print("Search :: pressedDeleteBtn!")
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "모든 기록을 삭제하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedTextFieldDeleteBtn() {
        self.searchTextField.textField.text = ""
        self.searchTextField.deleteBtn.isHidden = true
        self.searchText = ""
        self.searchTextField.layoutIfNeeded()
        self.listener?.search(keyword: "")
    }
}

// MARK: - UITableView
extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = DiarySearchSectionType(rawValue: section) else { return 0 }
        switch sectionType {
        case .search:
            if menualCount == 0 && searchText.count > 0 {
                return 317
            } else if menualCount == 0 && searchText.count == 0 {
                return 0
            } else {
                return 36
            }

        case .recentSearch:
            guard let count = listener?.recentSearchModel?.count else { return 0 }
            if count == 0 {
                return .leastNonzeroMagnitude
            } else {
                return 36
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("DiarySearch :: indexPath = \(indexPath)")
        guard let sectionType = DiarySearchSectionType(rawValue: indexPath.section) else { return 98 }
        switch sectionType {
        case .search:
            guard let model = listener?.searchResultsRelay.value[safe: indexPath.row] else {
                return 98
            }
            
            if model.isHide {
                return 75
            }

        case .recentSearch:
            guard let model = listener?.recentSearchModel?[indexPath.row],
                  let diary = model.diary else {
                return 98
            }
            
            if diary.isHide {
                return 75
            }
        }
        
        return 98
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 검색할 경우에는 두 section 모두 나타냄
        /*
        if menualCount == 0 {
            return 2
        } else {
            return 1
        }
        */
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = DiarySearchSectionType(rawValue: section) else { return UIView() }
        switch sectionType {
        case .search:
            if menualCount == 0 && searchText.count == 0 {
                return UIView()
            }
            tableView.addSubview(headerView)
            headerView.addSubview(divider)
            headerView.addSubview(searchEmptyView)

            headerView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(33)
            }
            
            divider.snp.remakeConstraints { make in
                make.top.equalTo(headerView.titleLabel.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(2)
            }

            searchEmptyView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(headerView.snp.bottom).offset(40)
                make.width.equalTo(170)
                make.height.equalTo(180)
            }
            
            return headerView

        case .recentSearch:
            let headerView = ListHeader(type: .search, rightIconType: .searchDelete)
            headerView.rightTextBtn.addTarget(self, action: #selector(pressedRecentSearchCellDeleteBtn), for: .touchUpInside)
            
            if let recentSearchCount: Int = listener?.recentSearchModel?.count {
                
                // 최근 검색 결과가 없으면 해당 Section도 나타나지 않도록
                if recentSearchCount == 0 {
                    return UIView()
                } else {
                    headerView.rightTextBtn.isEnabled = true
                }
            }
            
            let divider = Divider(type: ._2px)
            headerView.addSubview(divider)
            headerView.addSubview(recentSearchEmptyView)
            divider.snp.makeConstraints { make in
                make.top.equalTo(headerView.titleLabel.snp.bottom).offset(8)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(2)
            }
            
            recentSearchEmptyView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(headerView.snp.bottom).offset(40)
                make.width.equalTo(217)
                make.height.equalTo(180)
            }
            
            headerView.title = "RECENT"
            return headerView

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = DiarySearchSectionType(rawValue: section) else { return 0 }
        switch sectionType {
        case .search:
            return listener?.searchResultsRelay.value.count ?? 0

        case .recentSearch:
            guard let count = listener?.recentSearchModel?.count else { return 0 }
            
            // 총 5개까지만 노출되록 (UX)
            if count > 5 {
                return 5
            } else {
                return count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = DiarySearchSectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        let index = indexPath.row
        switch sectionType {
        case .search:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }
            
            guard let model = listener?.searchResultsRelay.value[safe: index],
                  let searchKeyword = self.searchTextField.textField.text else {
                return UITableViewCell()
            }
            
            cell.uuid = model.uuid
            if model.isHide {
                cell.listType = .hide
            } else {
                if let image = model.originalImage {
                    cell.listType = .bodyTextImage
                    cell.image = UIImage(data: image)
                } else {
                    cell.listType = .bodyText
                }
            }
            cell.title = model.title
            cell.date = model.createdAt.toString()
            cell.time = model.createdAt.toStringHourMin()
            cell.body = model.desc

            let pageCount = "\(model.pageNum)"
            var replies = ""
            if model.replies.count != 0 {
                replies = "\(model.replies.count)"
            }

            cell.searchKeyword = searchKeyword
            cell.pageCount = pageCount
            cell.reviewCount = replies
            
            return cell

        case .recentSearch:
            print("Search :: cell!")
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }

            guard let model = listener?.recentSearchModel?[index],
                  let data = model.diary else {
                return UITableViewCell()
            }
            
            print("Search :: cell! - 2")
            
            cell.uuid = model.uuid
            if data.isHide {
                cell.listType = .hide
            } else {
                if let image = data.originalImage {
                    cell.listType = .bodyTextImage
                    cell.image = UIImage(data: image)
                } else {
                    cell.listType = .bodyText
                }
            }
            cell.title = data.title
            cell.date = data.createdAt.toString()
            cell.time = data.createdAt.toStringHourMin()
            cell.body = data.desc

            let pageCount = "\(data.pageNum)"
            var replies = ""
            if data.repliesArr.count != 0 {
                replies = "\(data.replies.count)"
            }

            cell.searchKeyword = ""
            cell.pageCount = pageCount
            cell.reviewCount = replies
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = DiarySearchSectionType(rawValue: indexPath.section) else { return }
        let index = indexPath.row

        switch sectionType {
        case .search:
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
            print("Search :: tag = 0 - \(cell.uuid)")
            
            guard let model = listener?.searchResultsRelay.value[safe: index] else {
                return
            }
            
            print("Search :: 이거 = \(model.uuid), \(cell.uuid)")
            
            listener?.pressedSearchCell(diaryModel: model)

        case .recentSearch:
            print("Search :: 최근검색결과 touch! = \(indexPath.row)")
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
            
            guard let model = listener?.recentSearchModel?[index],
                  let diaryModel: DiaryModelRealm = model.diary
            else { return }
            
            print("Search :: 이거 = \(model.uuid), \(cell.uuid)")
            
            listener?.pressedRecentSearchCell(diaryModel: diaryModel)

        }
        print("Search :: 선택! = \(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let sectionType = DiarySearchSectionType(rawValue: indexPath.section) else { return nil }
        switch sectionType {
        case .search:
            return nil

        // 최근 검색어만 지원
        case .recentSearch:
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return nil }
            let modifyAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    self.listener?.deleteRecentSearchData(uuid: cell.uuid)
                    print("Search :: Update action ...")
                    success(true)
                })
            modifyAction.image = Asset._24px.delete.image.withRenderingMode(.alwaysTemplate)
            modifyAction.image?.withTintColor(.white)
            modifyAction.backgroundColor = Colors.tint.system.red.r200
            
            return UISwipeActionsConfiguration(actions: [modifyAction])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // 최근 검색어만 지원
        if indexPath.section == 1 {
            return true
        }
        
        return false
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

// MARK: - Dialog
extension DiarySearchViewController: DialogDelegate {
    func action(titleText: String) {
        switch titleText {
        case "모든 기록을 삭제하시겠어요?":
            listener?.deleteAllRecentSearchData()

        default:
            break
        }
    }
    
    func exit(titleText: String) {
        switch titleText {
        case "모든 기록을 삭제하시겠어요?":
            break
        default:
            break
        }
    }
    
    
}
