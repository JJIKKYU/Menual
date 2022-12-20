//
//  DiaryHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import RxRelay
import UIKit
import SnapKit
import Then
import FirebaseAnalytics
import RxViewController
import RealmSwift

enum TableCollectionViewTag: Int {
    case MomentsCollectionView = 0
    case MyMenualTableView = 1
}

protocol DiaryHomePresentableListener: AnyObject {
    func pressedSearchBtn()
    func pressedMyPageBtn()
    func pressedWritingBtn()
    func pressedDiaryCell(diaryModel: DiaryModelRealm)
    func pressedMomentsCell(momentsItem: MomentsItemRealm)
    func pressedMenualTitleBtn()
    func pressedFilterBtn()
    func pressedFilterResetBtn()
    func pressedDateFilterBtn()
    
    var lastPageNumRelay: BehaviorRelay<Int> { get }
    // var filteredDiaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]> { get }
    var filteredDiaryDic: BehaviorRelay<DiaryHomeFilteredSectionModel?> { get }
    var diaryDictionary: [String: DiaryHomeSectionModel] { get }
    var momentsRealm: MomentsRealm? { get }
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {
    
    enum ShowToastType {
        case writing
        case delete
        case edit
        case none
    }
    
    weak var listener: DiaryHomePresentableListener?
    // 스크롤 위치 저장하는 Dictionary
    var disposeBag = DisposeBag()
    
    var cellsectionNumberDic: [String: Int] = [:]
    var cellsectionNumberDic2: [Int: Int] = [:]
    
    let isFilteredRelay = BehaviorRelay<Bool>(value: false)
    var isShowToastDiaryResultRelay = BehaviorRelay<DiaryHomeViewController.ShowToastType?>(value: nil)
    private weak var weakToastView: ToastView?
    
    // MARK: - UI 코드
    private let tableViewHeaderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }

    lazy var naviView = MenualNaviView(type: .main).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1.setImage(Asset._24px.profile.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.rightButton1.addTarget(self, action: #selector(pressedMyPageBtn), for: .touchUpInside)
        
        $0.rightButton2.setImage(Asset._24px.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.rightButton2.addTarget(self, action: #selector(pressedSearchBtn), for: .touchUpInside)
        
        // #if DEBUG
        $0.menualTitleImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(pressedMenualBtn))
        $0.menualTitleImage.addGestureRecognizer(gesture)
        // #endif
    }

    lazy var writeBoxBtn = BoxButton(frame: CGRect.zero, btnStatus: .active, btnSize: .xLarge).then {
        $0.actionName = "write"
        $0.title = "N번째 메뉴얼 작성하기"
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
    }
    
    lazy var writeFAB = FAB(fabType: .primary, fabStatus: .default_).then {
        $0.actionName = "write"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
        $0.isHidden = true
    }
    
    lazy var scrollToTopFAB = FAB(fabType: .secondary, fabStatus: .default_).then {
        $0.actionName = "scrollToTop"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedScrollToTopFAB), for: .touchUpInside)
        $0.isHidden = true
    }

    lazy var momentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let flowlayout = CustomCollectionViewFlowLayout.init()
        flowlayout.itemSize = CGSize(width: self.view.bounds.width - 40, height: 120)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 10
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.setCollectionViewLayout(flowlayout, animated: true)
        $0.delegate = self
        $0.dataSource = self
        $0.register(MomentsCell.self, forCellWithReuseIdentifier: "MomentsCell")
        $0.register(DividerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "DividerView")
        $0.backgroundColor = .clear
        $0.decelerationRate = .fast
        $0.isPagingEnabled = false
        $0.tag = TableCollectionViewTag.MomentsCollectionView.rawValue
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let momentsCollectionViewPagination = Pagination().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfPages = 5
    }
    
    lazy var myMenualTitleView = ListHeader(type: .main, rightIconType: .filterAndCalender).then {
        $0.categoryName = "menualTitle"
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "MY MENUAL"
        // $0.layer.zPosition = 1
        $0.rightCalenderBtn.addTarget(self, action: #selector(pressedDateFilterBtn), for: .touchUpInside)
        $0.rightFilterBtn.addTarget(self, action: #selector(pressedFilterBtn), for: .touchUpInside)
    }
    
    lazy var myMenualTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.categoryName = "menual"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.estimatedRowHeight = 72
        $0.rowHeight = 72
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 72, right: 0)
        $0.tag = TableCollectionViewTag.MyMenualTableView.rawValue
        $0.separatorStyle = .none
    }
    
    private let filterEmptyView = UIView().then {
        let filterEmpty = Empty().then {
            $0.screenType = .main
            $0.mainType = .filter
        }
        let filterEmptyHeaderDivider = Divider(type: ._2px).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        $0.addSubview(filterEmpty)
        $0.addSubview(filterEmptyHeaderDivider)
        
        filterEmptyHeaderDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.equalTo(2)
        }
        
        filterEmpty.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(filterEmptyHeaderDivider.snp.bottom).offset(112)
            make.width.equalToSuperview()
            make.height.equalTo(180)
        }
        
        $0.isHidden = true
    }
    
    private let emptyView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let divider = Divider(type: ._2px).then {
            $0.backgroundColor = Colors.grey.g700
        }
        let empty = Empty().then {
            $0.screenType = .main
            $0.mainType = .main
        }
        $0.addSubview(divider)
        $0.addSubview(empty)
        
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(2)
        }
        
        empty.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(112)
            make.width.equalTo(188)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
        }
        $0.isHidden = true
    }
    
    private lazy var momentsEmptyView = MomentsEmptyView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.writingBtn.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
        $0.isHidden = true
    }
    
    // MARK: - VC 코드
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
        print("DiaryHome!")
        setViews()
        bind()
    }
    
    convenience init(screenName3: String) {
        self.init()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self        
    }
    
    func setViews() {
        self.view.backgroundColor = Colors.background
        
        self.view.addSubview(naviView)
        self.view.addSubview(writeBoxBtn)
        
        self.view.addSubview(myMenualTableView)
        self.view.addSubview(filterEmptyView)
        self.view.addSubview(writeFAB)
        self.view.addSubview(scrollToTopFAB)
        self.view.addSubview(emptyView)
        self.view.addSubview(momentsEmptyView)
        self.view.addSubview(myMenualTitleView)
        myMenualTableView.tableHeaderView = tableViewHeaderView
        
        tableViewHeaderView.addSubview(momentsCollectionView)
        tableViewHeaderView.addSubview(momentsCollectionViewPagination)
        
        naviView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        self.view.bringSubviewToFront(naviView)
        self.view.bringSubviewToFront(writeBoxBtn)
        self.view.bringSubviewToFront(tableViewHeaderView)
        self.view.bringSubviewToFront(writeFAB)
        self.view.bringSubviewToFront(scrollToTopFAB)
        self.view.bringSubviewToFront(myMenualTitleView)
        
        myMenualTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom)
        }
        
        tableViewHeaderView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(210)
        }
        self.view.layoutIfNeeded()
        
        print("UIApplication.topSafeAreaHeight = \(UIApplication.topSafeAreaHeight)")
        
        momentsCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(125)
        }
        
        momentsEmptyView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(momentsCollectionView.snp.top).offset(20)
            make.bottom.equalTo(momentsCollectionView.snp.bottom).inset(20)
        }
        
        momentsCollectionViewPagination.snp.makeConstraints { make in
            make.top.equalTo(momentsCollectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(4)
        }
        
        myMenualTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(momentsCollectionViewPagination.snp.bottom).offset(24)
            make.height.equalTo(22)
        }
        
        writeBoxBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(34)
        }
        
        filterEmptyView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(tableViewHeaderView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        writeFAB.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.width.height.equalTo(56)
        }
        
        scrollToTopFAB.snp.makeConstraints { make in
            make.trailing.equalTo(writeFAB)
            make.bottom.equalTo(writeFAB.snp.top).inset(-16)
            make.width.height.equalTo(56)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(tableViewHeaderView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        listener?.lastPageNumRelay
            .subscribe(onNext: { [weak self] num in
                guard let self = self else { return }
                print("diaryHome :: num!! = \(num)")
                if self.isFilteredRelay.value {
                    self.myMenualTitleView.pageNumber = num
                } else {
                    if num == 0 {
                        print("DiaryHome :: EmptyView")
                        self.setEmptyView(isEnabled: true)
                    } else {
                        self.setEmptyView(isEnabled: false)
                    }
                    
                    self.writeBoxBtn.title = String(num + 1) + "번째 메뉴얼 작성하기"
                    self.myMenualTitleView.pageNumber = num
                    self.reloadTableView()
                }
            })
            .disposed(by: self.disposeBag)
        
        listener?.filteredDiaryDic
            .subscribe(onNext: { [weak self] diarySectionModel in
                guard let self = self else { return }
                guard let diarySectionModel = diarySectionModel else { return }
                if self.isFilteredRelay.value == false { return }
                
                if diarySectionModel.allCount == 0 {
                    self.filterEmptyView.isHidden = false
                } else {
                    self.filterEmptyView.isHidden = true
                }
                
                self.reloadTableView()
            })
            .disposed(by: disposeBag)
        
        isFilteredRelay
            .subscribe(onNext: { [weak self] isFiltered in
                guard let self = self else { return }
                self.setFilterStatus(isFiltered: isFiltered)
                if isFiltered {
                    self.setEmptyView(isEnabled: false)
                } else {
                    if self.myMenualTitleView.pageNumber == 0 {
                        self.setEmptyView(isEnabled: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .withLatestFrom(isShowToastDiaryResultRelay)
            .subscribe(onNext: { [weak self] mode in
                guard let self = self else { return }
                print("DiaryHome :: rxViewWillAppear! -> mode = \(mode)")
                switch mode {
                case .writing:
                    self.showToastDiaryResult(mode: .writing)
                case .edit:
                    self.showToastDiaryResult(mode: .edit)
                case .delete:
                    self.showToastDiaryResult(mode: .delete)
                case nil:
                    break
                case .some(.none):
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setEmptyView(isEnabled: Bool) {
        print("DiaryHome :: setEmptyView = \(isEnabled)")
        switch isEnabled {
        case true:
            emptyView.isHidden = false

        case false:
            emptyView.isHidden = true
        }
    }
    
    func scrollToDateFilter(yearDateFormatString: String) {
        let isFiltered: Bool = isFilteredRelay.value
        switch isFiltered {
        case true:
            guard let diaryDictionary = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return }
            guard let data = diaryDictionary.filter ({ $0.value.sectionName == yearDateFormatString }).first else { return }
            myMenualTableView.scrollToRow(at: IndexPath(row: 0, section: data.value.sectionIndex), at: .middle, animated: true)

        case false:
            guard let diaryDictionary = listener?.diaryDictionary else { return }
            guard let data = diaryDictionary.filter ({ $0.value.sectionName == yearDateFormatString }).first else { return }
            print("DiaryHome :: data = \(data)")
            myMenualTableView.scrollToRow(at: IndexPath(row: 0, section: data.value.sectionIndex), at: .middle, animated: true)
        }
    }
    
    func deleteTableViewSection(section: Int) {
        myMenualTableView.beginUpdates()
        let indexSet = IndexSet(integer: section)
        myMenualTableView.deleteSections(indexSet, with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func deleteTableViewRow(section: Int, row: Int) {
        myMenualTableView.beginUpdates()
        myMenualTableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func reloadTableViewRow(section: Int, row: Int) {
        myMenualTableView.beginUpdates()
        myMenualTableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func insertTableViewSection() {
        myMenualTableView.beginUpdates()
        let indexSet = IndexSet(integer: myMenualTableView.numberOfSections )
        myMenualTableView.insertSections(indexSet, with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func insertTableViewRow(section: Int, row: Int) {
        myMenualTableView.beginUpdates()
        myMenualTableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
}

// MARK: - IBAction
extension DiaryHomeViewController {
    @objc
    func pressedSearchBtn(_ button: UIButton) {
        listener?.pressedSearchBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedMyPageBtn(_ button: UIButton) {
        listener?.pressedMyPageBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedFABWritingBtn(_ button: UIButton) {
        print("FABWritingBtn Pressed!, button = \(button)")
        listener?.pressedWritingBtn()
        button.actionName = "write"
        if button == writeBoxBtn {
            MenualLog.logEventAction(responder: button, parameter: ["type" : "box"])
        } else if button == writeFAB {
            MenualLog.logEventAction(responder: button, parameter: ["type" : "fab"])
        }
    }
    
    @objc
    func pressedMenualBtn(_ button: UIButton) {
        print("메뉴얼 버튼 눌렀니?")
        listener?.pressedMenualTitleBtn()
    }
    
    @objc
    func pressedDateFilterBtn(_ button: UIButton) {
        print("pressedLightCalenderBtn")
        listener?.pressedDateFilterBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedFilterBtn(_ button: UIButton) {
        print("pressedFilterBtn")
        listener?.pressedFilterBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedFilterResetBtn(_ button: UIButton) {
        print("DiaryHome :: filterReset!!")
        button.actionName = "filterReset"
        listener?.pressedFilterResetBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedScrollToTopFAB(_ button: UIButton) {
        print("DiaryHome :: pressedScrollToTopFAB!!")
        myMenualTableView.setContentOffset(.zero, animated: true)
        MenualLog.logEventAction(responder: button)
    }
}

// MARK: - Scroll View
extension DiaryHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableCollectionViewTag = TableCollectionViewTag(rawValue: scrollView.tag) else { return }
        
        switch tableCollectionViewTag {
        case .MomentsCollectionView:
            momentsPagination(scrollView)

        case .MyMenualTableView:
            attachTopMyMenualTitleView(scrollView)
        }
    }
    
    // 스크롤시 상단에 titleView가 고정되도록
    func attachTopMyMenualTitleView(_ scrollView: UIScrollView) {
        guard let tableCollectionViewTag = TableCollectionViewTag(rawValue: scrollView.tag) else { return }
        // myMenualTableView일때만 작동하도록
        if case .MyMenualTableView = tableCollectionViewTag {
            // print("DiaryHome :: contents offset = \(scrollView.contentOffset.y)")
            let offset = scrollView.contentOffset.y
            // TitleView를 넘어서 스크롤할 경우
            if offset > 165 {
                // print("DiaryHome :: contents > 155")
                setFABMode(isEnabled: true)
                myMenualTitleView.AppShadow(.shadow_6)
                myMenualTitleView.backgroundColor = Colors.background
                myMenualTitleView.titleLabel.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(20)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(22)
                }
                myMenualTitleView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview()
                    make.width.equalToSuperview()
                    make.top.equalTo(naviView.snp.bottom)
                    make.height.equalTo(44)
                }
            } else {
                // print("DiaryHome :: contents <= 155")
                setFABMode(isEnabled: false)
                myMenualTitleView.AppShadow(.shadow_0)
                myMenualTitleView.backgroundColor = .clear
                myMenualTitleView.titleLabel.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(20)
                    make.top.equalToSuperview()
                    make.height.equalTo(22)
                }
                myMenualTitleView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview()
                    make.width.equalToSuperview()
                    make.top.equalTo(momentsCollectionViewPagination.snp.bottom).offset(24)
                    make.height.equalTo(22)
                }
            }
        }
    }

    // isEnabled == true : FABMode
    // isEnabled == false : FABMode 해제
    func setFABMode(isEnabled: Bool) {
        switch isEnabled {
        case true:
            writeBoxBtn.isHidden = true
            scrollToTopFAB.isHidden = false
            writeFAB.isHidden = false

        case false:
            writeBoxBtn.isHidden = false
            scrollToTopFAB.isHidden = true
            writeFAB.isHidden = true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }

    func momentsPagination(_ scrollView: UIScrollView) {
        guard let tableCollectionViewTag = TableCollectionViewTag(rawValue: scrollView.tag) else { return }

        if case .MomentsCollectionView = tableCollectionViewTag {
            print("DiaryHome :: momentsPagination!")
            let width = scrollView.bounds.size.width
            // Init할 때 width가 모두 그려지지 않을때 오류 발생
            if width == 0 { return }
            // 좌표보정을 위해 절반의 너비를 더해줌
            let x = scrollView.contentOffset.x + (width/2)
           
            let newPage = Int(x / width)
            if momentsCollectionViewPagination.currentPage != newPage {
                momentsCollectionViewPagination.currentPage = newPage
            }
        }
    }
}

// MARK: - UITableView Deleagte, Datasource
extension DiaryHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 첫번재 섹션일 경우에는 넓게 안띄움
        if section == 0 {
            return 44
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilteredRelay.value {
            // guard let monthMenualCount = filteredCellsectionNumberDic2[section] else { return 0 }\
            guard let diaryDictionary = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return 0 }
            guard let findDict = diaryDictionary.filter ({ $0.value.sectionIndex == section }).first
            else { return 0 }

            return findDict.value.diaries.count
        } else {
            guard let diaryDictionary = listener?.diaryDictionary else { return 0 }
            guard let findDict = diaryDictionary.filter({ $0.value.sectionIndex == section }).first else { return 0 }
            
            return findDict.value.diaries.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFilteredRelay.value {
            guard let diaryDictionary = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return 0 }
            return diaryDictionary.count
        } else {

            guard let diaryDictionary = listener?.diaryDictionary else { return 0 }
            return diaryDictionary.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { return UITableViewCell() }
        let index: Int = indexPath.row
        var lastIndex: Int = 0
        let section: Int = indexPath.section

        var dataModel: DiaryModelRealm?
        let defaultCell = UITableViewCell()
        switch self.isFilteredRelay.value {
        case true:
            guard let diaryDictionry: [String: DiaryHomeSectionModel] = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return defaultCell }
            guard let dataDictionary = diaryDictionry.filter ({ $0.value.sectionIndex == section }).first else { return defaultCell }
            guard let data = dataDictionary.value.diaries[safe: index] else { return defaultCell }
            lastIndex = dataDictionary.value.diaries.count
            dataModel = data

        case false:
            guard let diaryDictionry: [String: DiaryHomeSectionModel] = listener?.diaryDictionary else { return defaultCell }
            guard let dataDictionary = diaryDictionry.filter ({ $0.value.sectionIndex == section }).first else { return defaultCell }
            guard let data = dataDictionary.value.diaries[safe: index] else { return defaultCell }
            lastIndex = dataDictionary.value.diaries.count
            dataModel = data
        }
        guard let dataModel = dataModel else { return UITableViewCell() }
        
              
        if dataModel.isHide {
            cell.listType = .hide
        } else {
            if let image = dataModel.originalImage {
                cell.listType = .textAndImage
                DispatchQueue.main.async {
                    cell.image = UIImage(data: image)
                }
            } else {
                cell.image = nil
                cell.listType = .normal
            }
        }
        
        cell.title = dataModel.title
        cell.date = dataModel.createdAt.toString()
        cell.time = dataModel.createdAt.toStringHourMin()
        
        let pageCount = "\(dataModel.pageNum)"
        var replies = ""
        if dataModel.replies.count != 0 {
            replies = "\(dataModel.replies.count)"
        }

        cell.pageCount = pageCount
        cell.reviewCount = replies
        cell.testModel = dataModel
        
        // 마지막 셀일 경우에는 divider 제거
        if index == lastIndex - 1 {
            cell.divider.isHidden = true
        } else {
            cell.divider.isHidden = false
        }
        
        cell.actionName = "cell"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListCell,
              let data = cell.testModel
        else { return }

        let parameter: [String: Any] = [
            "page" : data.pageNum,
            "createdAt" : data.createdAt,
            "replyCount" : data.repliesArr.count,
            "readCount" : data.readCount,
            "image" : data.image,
            "reminder" : data.reminder?.isEnabled ?? false
        ]
        MenualLog.logEventAction(responder: cell, parameter: parameter)
        listener?.pressedDiaryCell(diaryModel: data)
    }
    //reloadJJIKKYU() -> JJIKKYU Love YangSSuz <3 진균이는 내가 아는 사람중에 제일 멋져!!! ~v~
    func reloadTableView() {
        print("reloadTableView!")
        // self.isFiltered = isFiltered
        // self.isFilteredRelay.accept(isFiltered)
        myMenualTableView.reloadData()
        momentsCollectionView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionListHeader = SectionListHeaderView()

        sectionListHeader.backgroundColor = .clear
        sectionListHeader.title = "2022.999"
        
        guard let diaryDictionary = listener?.diaryDictionary,
              let sectionName = diaryDictionary.filter ({ $0.value.sectionIndex == section }).first?.value.sectionName
        else { return sectionListHeader }
        
        sectionListHeader.title = sectionName
        
        return sectionListHeader
    }
}

// MARK: - UICollectionView Delegate, Datasource
extension DiaryHomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func reloadCollectionView() {
        print("DiaryHome :: reloadCollectionView!")
        self.momentsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            print("kind = \(kind)")
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DividerView", for: indexPath) as! DividerView
            print("sectionHeader = \(sectionHeader)")
            return sectionHeader

        default:
            return UICollectionReusableView()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            return CGSize.zero
            
        default:
            return CGSize.zero
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            return 1
            
        default:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            // 초기에는 Realm도 설정되어 있지 않으므로 따로 설정
            guard let momentsCount = listener?.momentsRealm?.itemsArr.count else {
                print("DiaryHome :: 여기!?")
                self.momentsEmptyView.isHidden = false
                self.momentsCollectionViewPagination.numberOfPages = 0
                return  0
            }
            print("DiaryHome :: momentsCount = \(momentsCount)")

            if momentsCount == 0 {
                self.momentsEmptyView.isHidden = false
                self.momentsCollectionViewPagination.numberOfPages = 0
                return 0
            } else {
                self.momentsEmptyView.isHidden = true
                self.momentsCollectionViewPagination.numberOfPages = momentsCount
                return momentsCount
            }

        default:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MomentsCell", for: indexPath) as? MomentsCell else { return UICollectionViewCell() }
            guard let data = listener?.momentsRealm?.itemsArr[safe: indexPath.row] else { return UICollectionViewCell() }
            
            cell.tagTitle = "MENUAL TIPS"
            cell.momentsTitle = data.title
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            let width = UIScreen.main.bounds.width - 40
            return CGSize(width: width, height: 125)
            
        default:
            return CGSize(width: 32, height: 32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            print("MomentsCollectionView Selected!")
            guard let data = listener?.momentsRealm?.itemsArr[safe: indexPath.row] else { return }
            listener?.pressedMomentsCell(momentsItem: data)
            
        default:
            return
        }
    }
}

// MARK: - Filter
extension DiaryHomeViewController {
    func setFilterStatus(isFiltered: Bool) {
        print("diaryHome :: setFilterStatus = \(isFiltered)")
        // 이미 적용된 target 제거
        self.writeBoxBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.writeFAB.removeTarget(nil, action: nil, for: .allEvents)

        switch isFiltered {
        case true:
            print("diaryHome :: isFiltered! = true")
            self.myMenualTitleView.title = "TOTAL PAGE"
            self.myMenualTitleView.rightFilterBtnIsEnabled = true
            
            self.writeBoxBtn.title = "필터 초기화"
            self.writeBoxBtn.isFiltered = .enabled
            
            self.writeFAB.isFiltered = .enabled

            self.writeBoxBtn.addTarget(self, action: #selector(pressedFilterResetBtn), for: .touchUpInside)
            self.writeFAB.addTarget(self, action: #selector(pressedFilterResetBtn), for: .touchUpInside)
            
            
        case false:
            print("diaryHome :: isFiltered! = false")
            self.myMenualTitleView.title = "MY MENUAL"
            self.myMenualTitleView.rightFilterBtnIsEnabled = false
            self.writeBoxBtn.isFiltered = .disabled
            self.writeFAB.isFiltered = .disabled
            
            let lastPageNum: Int = self.listener?.lastPageNumRelay.value ?? 0
            self.writeBoxBtn.title = String(lastPageNum + 1) + "번째 메뉴얼 작성하기"
            self.myMenualTitleView.pageNumber = lastPageNum

            self.writeBoxBtn.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
            self.writeFAB.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
            self.filterEmptyView.isHidden = true
            self.reloadTableView()
        }
    }
}

// MARK: - Toast
extension DiaryHomeViewController {
    func showToastDiaryResult(mode: DiaryHomeViewController.ShowToastType) {
        print("DiaryHome :: showToastDiaryResult!")
        switch mode {
        case .writing:
            let toastView = showToast(message: "메뉴얼 등록이 완료되었습니다.")
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "write"])

        case .edit:
            let toastView = showToast(message: "메뉴얼 등록이 수정되었습니다.")
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "edit"])
            
        case .delete:
            let toastView = showToast(message: "메뉴얼 삭제를 완료했어요.")
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "delete"])
            
        case .none:
            break
        }

        isShowToastDiaryResultRelay.accept(nil)
    }
}

// MARK: - UIGestureRecognizerDelegate / BackSwipe Bug
extension DiaryHomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
