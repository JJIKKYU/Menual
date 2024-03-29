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
import MenualEntity
import DesignSystem
import MenualUtil

public protocol DiarySearchPresentableListener: AnyObject {
    var searchResultsRelay: BehaviorRelay<[DiaryModelRealm]> { get }
    var recentSearchModel: [DiarySearchModelRealm]? { get }

    func pressedBackBtn(isOnlyDetach: Bool)
    func search(keyword: String)
    func pressedSearchCell(diaryModel: DiaryModelRealm)
    func pressedRecentSearchCell(diaryModel: DiaryModelRealm)
    func deleteAllRecentSearchData()
    func deleteRecentSearchData(uuid: String)
}

public final class DiarySearchViewController: UIViewController, DiarySearchViewControllable {
    
    public enum DiarySearchSectionType: Int {
        case search = 0
        case recentSearch = 1
    }

    weak public var listener: DiarySearchPresentableListener?
    var disposeBag = DisposeBag()
    
    var menualCount: Int = 0
    var searchText: String = ""
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = MenualString.search_title
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
        $0.separatorStyle = .none
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
        $0.categoryName = "bar"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textField.delegate = self
        $0.deleteBtn.addTarget(self, action: #selector(pressedTextFieldDeleteBtn), for: .touchUpInside)
    }
    
    private lazy var headerView = ListHeader(type: .search, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "\(MenualString.home_title_total_page) \(menualCount)"
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
    
    public override func viewDidLoad() {
      super.viewDidLoad()
        view.backgroundColor = Colors.background
        setViews()
        bind()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.textField.becomeFirstResponder()
        MenualLog.logEventAction("search_appear")
        // (navigationController as? NavigationController)?.isDisabledFullWidthBackGesture = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // (navigationController as? NavigationController)?.isDisabledFullWidthBackGesture = false
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // dch_checkDeallocation()
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    deinit {
        tableView.delegate = nil
        searchTextField.textField.delegate = nil

        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        print("deinit!")
    }
    
    func bind() {
        searchTextField.textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                
                if keyword == "#debug" {
                    let value = UserDefaults.standard.bool(forKey: "debug")
                    print("Debug :: value = \(value)")
                    UserDefaults.standard.setValue(!value, forKey: "debug")
                    let _ = self.showToast(message: "Debug Mode가 \(!value == true ? "켜졌습니다" : "꺼졌습니다")")
                } else if keyword == "#test" {
                    let value = UserDefaults.standard.bool(forKey: "test")
                    UserDefaults.standard.setValue(!value, forKey: "test")
                    let _ = self.showToast(message: "Test Mode가 \(!value == true ? "켜졌습니다" : "꺼졌습니다")")
                }

                self.listener?.search(keyword: keyword)
                self.searchText = keyword
            })
            .disposed(by: disposeBag)
        
        listener?.searchResultsRelay
            .subscribe(onNext: { [weak self] results in
                guard let self = self else { return }
                let count = results.count
                self.menualCount = count
                self.headerView.title = "\(MenualString.home_title_total_page) \(count)"
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
    public func reloadSearchTableView() {
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
    
    public func updateRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.reloadRows(at: indexPaths, with: .automatic)
        reloadSearchTableView()
    }
    
    public func insertRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        tableView.beginUpdates()
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        reloadSearchTableView()
    }
    
    public func deleteRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType) {
        tableView.beginUpdates()
        let indexPaths = indexs.map { IndexPath(item: $0, section: section.rawValue) }
        tableView.deleteRows(at: indexPaths, with: .fade)
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
        showDialog(
            dialogScreen: .diarySearch(.delete),
             size: .small,
             buttonType: .twoBtn,
             titleText: "모든 기록을 삭제하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedTextFieldDeleteBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        self.searchTextField.textField.text = ""
        self.searchTextField.deleteBtn.isHidden = true
        self.searchText = ""
        self.searchTextField.layoutIfNeeded()
        self.listener?.search(keyword: "")
    }
}

// MARK: - UITableView
extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = DiarySearchSectionType(rawValue: section) else { return 0 }
        switch sectionType {
        case .search:
            if menualCount == 0 && searchText.count > 0 {
                return 340
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
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            // 숨김처리 되어있을때는 0으로
            if let cell = tableView.cellForRow(at: indexPath) as? RecentSearchCell {
                if cell.isHidden == true {
                    return 0
                }
            }
            
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
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
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
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
                make.width.equalToSuperview()
                make.height.equalTo(200)
            }
            
            return headerView

        case .recentSearch:
            let headerView = ListHeader(type: .search, rightIconType: .searchDelete)
            headerView.rightTextBtn.addTarget(self, action: #selector(pressedRecentSearchCellDeleteBtn), for: .touchUpInside)
            
            if let recentSearchCount: Int = listener?.recentSearchModel?.count {
                
                // 최근 검색 결과가 없으면 해당 Section도 나타나지 않도록
                // 현재 검색 중이고, 검색 결과가 있으면 노출되지 않도록
                if recentSearchCount == 0 || listener?.searchResultsRelay.value.count ?? 0 > 0 {
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
                make.width.equalToSuperview()
                make.height.equalTo(200)
            }
            
            headerView.title = MenualString.search_title_recent
            return headerView

        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = DiarySearchSectionType(rawValue: section) else { return 0 }
        switch sectionType {
        case .search:
            return listener?.searchResultsRelay.value.count ?? 0

        case .recentSearch:
            guard let count = listener?.recentSearchModel?.count else { return 0 }
            
            // 총 5개까지만 노출되록 (UX)
            return count
            /*
            if count > 5 {
                return 5
            } else {
                return count
            }
             */
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                if model.image {
                    cell.listType = .textAndImage
                    model.getThumbImage { [weak cell] imageData in
                        guard let cell = cell,
                              let imageData: Data = imageData
                        else { return }

                        if let image: UIImage = UIImage(data: imageData) {
                            let resizeImageData = UIImage().imageWithImage(
                                sourceImage: image,
                                scaledToWidth: 100
                            )
                            cell.image = resizeImageData
                        }
                    }
                }
                else {
                    cell.listType = .bodyText
                }
            }
            cell.listScreen = .search
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
            cell.actionName = "resultCell"
            
            return cell

        case .recentSearch:
            print("Search :: cell!")
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }

            guard let model = listener?.recentSearchModel?[index],
                  let data = model.diary else {
                return UITableViewCell()
            }
            
            // 현재 검색중일 경우에는 숨김처리
            if listener?.searchResultsRelay.value.count ?? 0 > 0 {
                cell.isHidden = true
                return cell
            } else {
                cell.isHidden = false
            }

            // 5개가 넘어갔을 경우에는 숨김처리
            if index >= 5 {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            
            print("Search :: cell! - 2")
            
            cell.uuid = model.uuid
            if data.isHide {
                cell.listType = .hide
            } else {
                if data.image {
                    cell.listType = .bodyTextImage
                    model.diary?.getThumbImage { [weak cell] imageData in
                        guard let cell = cell,
                              let imageData: Data = imageData
                        else { return }
                        cell.image = UIImage(data: imageData)
                    }
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
            cell.actionName = "recentCell"
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            
            let parameter: [String: Any] =
            [
                "keyword": searchText,
                "page" : model.pageNum,
                "createdAt" : model.createdAt,
                "replyCount" : model.createdAt,
                "readCount" : model.readCount,
                "image" : model.image,
                "reminder" : model.reminder?.isEnabled ?? false
            ]
            MenualLog.logEventAction(responder: cell, parameter: parameter)
            listener?.pressedSearchCell(diaryModel: model)

        case .recentSearch:
            print("Search :: 최근검색결과 touch! = \(indexPath.row)")
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
            
            guard let model = listener?.recentSearchModel?[index],
                  let diaryModel: DiaryModelRealm = model.diary
            else { return }
            
            print("Search :: 이거 = \(model.uuid), \(cell.uuid)")
            
            let parameter: [String: Any] =
            [
                "keyword": searchText,
                "page" : diaryModel.pageNum,
                "createdAt" : diaryModel.createdAt,
                "replyCount" : diaryModel.createdAt,
                "readCount" : diaryModel.readCount,
                "image" : diaryModel.image,
                "reminder" : diaryModel.reminder?.isEnabled ?? false
            ]
            MenualLog.logEventAction(responder: cell, parameter: parameter)
            listener?.pressedRecentSearchCell(diaryModel: diaryModel)

        }
        print("Search :: 선택! = \(indexPath)")
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let sectionType = DiarySearchSectionType(rawValue: indexPath.section) else { return nil }
        switch sectionType {
        case .search:
            return nil

        // 최근 검색어만 지원
        case .recentSearch:
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return nil }
            let modifyAction = UIContextualAction(style: .normal, title:  "", handler: { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    guard let self = self else { return success(false) }
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
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
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
        print("keyboardWillShow!")
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
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
    public func action(dialogScreen: DesignSystem.DialogScreen) {
        if case .diarySearch(let diarySearchDialog) = dialogScreen {
            switch diarySearchDialog {
            case .delete:
                listener?.deleteAllRecentSearchData()
            }
        }
    }
    
    public func exit(dialogScreen: DesignSystem.DialogScreen) {
        if case .diarySearch(let diarySearchDialog) = dialogScreen {
            switch diarySearchDialog {
            case .delete:
                break
            }
        }
    }
}
