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

enum TableCollectionViewTag: Int {
    case MomentsCollectionView = 0
    case MyMenualTableView = 1
}

protocol DiaryHomePresentableListener: AnyObject {
    func pressedSearchBtn()
    func pressedMyPageBtn()
    func pressedMomentsTitleBtn()
    func pressedMomentsMoreBtn()
    func pressedWritingBtn()
    
    func getMyMenualCount() -> Int
    func getMyMenualArr() -> [DiaryModel]
    
    func pressedDiaryCell(diaryModel: DiaryModel)
    
    func pressedMenualTitleBtn()
    
    func pressedFilterBtn()
    func pressedFilterResetBtn()
    func pressedDateFilterBtn()
    
    var lastPageNumRelay: BehaviorRelay<Int> { get }
    var diaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]> { get }
    var filteredDiaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]> { get }
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {
    
    weak var listener: DiaryHomePresentableListener?
    // 스크롤 위치 저장하는 Dictionary
    var disposeBag = DisposeBag()
    
    var sectionNameDic: [Int: String] = [:]
    
    var filteredSectionNameDic: [Int: String] = [:]
    
    var cellsectionNumberDic: [String: Int] = [:]
    var cellsectionNumberDic2: [Int: Int] = [:]
    
    var filteredCellsectionNumberDic: [String: Int] = [:]
    var filteredCellsectionNumberDic2: [Int: Int] = [:]
    
    let isFilteredRelay = BehaviorRelay<Bool>(value: false)
    private let isDraggingRelay = BehaviorRelay<Bool>(value: false)
    
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
    
    // TODO: CustomView로 만들기
    lazy var writeBoxBtn = BoxButton(frame: CGRect.zero, btnStatus: .active, btnSize: .xLarge).then {
        $0.title = "N번째 메뉴얼 작성하기"
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
    }
    
    lazy var writeFAB = FAB(fabType: .primary, fabStatus: .default_).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
        $0.isHidden = true
    }
    
    lazy var scrollToTopFAB = FAB(fabType: .secondary, fabStatus: .default_).then {
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
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "MY MENUAL"
        $0.rightCalenderBtn.addTarget(self, action: #selector(pressedDateFilterBtn), for: .touchUpInside)
        $0.rightFilterBtn.addTarget(self, action: #selector(pressedFilterBtn), for: .touchUpInside)
    }
    
    lazy var myMenualTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
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
        $0.separatorStyle = .singleLine
        $0.separatorColor = Colors.grey.g700
    }
    
    private let indicatorView = IndicatorView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.alpha = 1
        $0.frame = CGRect(x: 0, y: 0, width: 58, height: 20)
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
    
    func setViews() {
        self.view.backgroundColor = Colors.background
        
        self.view.addSubview(naviView)
        self.view.addSubview(writeBoxBtn)
        self.view.addSubview(indicatorView)
        
        self.view.addSubview(myMenualTableView)
        self.view.addSubview(filterEmptyView)
        self.view.addSubview(writeFAB)
        self.view.addSubview(scrollToTopFAB)
        self.view.addSubview(emptyView)
        myMenualTableView.tableHeaderView = tableViewHeaderView
        
        tableViewHeaderView.addSubview(momentsCollectionView)
        tableViewHeaderView.addSubview(momentsCollectionViewPagination)
        tableViewHeaderView.addSubview(myMenualTitleView)
        
        naviView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        self.view.bringSubviewToFront(naviView)
        self.view.bringSubviewToFront(writeBoxBtn)
        self.view.bringSubviewToFront(indicatorView)
        self.view.bringSubviewToFront(tableViewHeaderView)
        self.view.bringSubviewToFront(writeFAB)
        self.view.bringSubviewToFront(scrollToTopFAB)
        
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
        
        indicatorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(56)
            make.height.equalTo(20)
            make.centerY.equalTo(myMenualTableView)
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
                }
            })
            .disposed(by: self.disposeBag)
        
        listener?.diaryMonthSetRelay
            .subscribe(onNext: { [weak self] diaryYearModelArr in
                guard let self = self else { return }
                
                print("DiaryHome :: diaryMonthSetRelay")
                
                var sectionCount: Int = 0
                for diaryYearModel in diaryYearModelArr {
                    // ["2022JUL", "2022JUM"]
                    guard let monthArr = diaryYearModel.months?.getMonthArr() else { return }
                    
                    for month in monthArr {
                        let sectionName: String = "\(diaryYearModel.year)\(month)"
                        print("sectionName = \(sectionName), sectionCount = \(sectionCount)")
                        self.sectionNameDic[sectionCount] = sectionName
                        self.cellsectionNumberDic[sectionName] = sectionCount
                        self.cellsectionNumberDic2[sectionCount] =  diaryYearModel.months?.getMenualCountWithMonth(MM: month) ?? 0
                        
                        sectionCount += 1
                    }
                }

                print("sectionCount = \(sectionCount)")
                print("cell, for문 끝! sectionCount = \(sectionCount), sectionNameDic = \(self.sectionNameDic), cellSectionNumberDic = \(self.cellsectionNumberDic), cellsectionNumberDic2 = \(self.cellsectionNumberDic2)")

                self.setEmptyView(isEnabled: false)
                self.myMenualTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        listener?.filteredDiaryMonthSetRelay
            .subscribe(onNext: { [weak self] diaryYearModelArr in
                guard let self = self else { return }
                if self.isFilteredRelay.value == false { return }
                print("DiaryHome :: filteredDiaryMonthSetRelay, count = \(diaryYearModelArr.count)")
                
                // 필터는 계속 변형되므로 Relay가 업데이트 될때마다 담은 정보 초기화
                self.filteredSectionNameDic = [:]
                self.filteredCellsectionNumberDic = [:]
                self.filteredCellsectionNumberDic2 = [:]
                
                var sectionCount: Int = 0
                var allCount: Int = 0
                for diaryYearModel in diaryYearModelArr {
                    // ["2022JUL", "2022JUM"]
                    guard let monthArr = diaryYearModel.months?.getMonthArr() else { return }
                    
                    for month in monthArr {
                        let sectionName: String = "\(diaryYearModel.year)\(month)"
                        print("sectionName = \(sectionName), sectionCount = \(sectionCount)")
                        self.filteredSectionNameDic[sectionCount] = sectionName
                        self.filteredCellsectionNumberDic[sectionName] = sectionCount
                        self.filteredCellsectionNumberDic2[sectionCount] =  diaryYearModel.months?.getMenualCountWithMonth(MM: month) ?? 0
                        
                        sectionCount += 1
                    }
                    
                    allCount += diaryYearModel.months?.allCount ?? 0
                }

                // 필터 결과 하나도 없을 경우
                if allCount == 0 {
                    self.filterEmptyView.isHidden = false
                } else {
                    self.filterEmptyView.isHidden = true
                }

                print("DiaryHome :: filter 후 sectionCount = \(sectionCount), allCount = \(allCount)")
                self.myMenualTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 드래그를 하고 있을 경우 true
        // 드래그를 멈추는 시점에 false
        isDraggingRelay
            .subscribe(onNext: { [weak self] isDragging in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch isDragging {
                    case true:
                        self.indicatorView.isHidden = false
                    case false:
                        self.indicatorView.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        isFilteredRelay
            .subscribe(onNext: { [weak self] isFiltered in
                guard let self = self else { return }
                self.setFilterStatus(isFiltered: isFiltered)
                if isFiltered {
                    self.setEmptyView(isEnabled: false)
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
}

// MARK: - IBAction
extension DiaryHomeViewController {
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
        listener?.pressedMomentsTitleBtn()
        print("Moments Title Pressed!")
    }
    
    @objc
    func pressedMomentsMoreBtn() {
        listener?.pressedMomentsMoreBtn()
        print("Moments More Pressed!")
    }
    
    @objc
    func pressedMyMenualBtn() {
        
    }
    
    @objc
    func pressedFABWritingBtn() {
        print("FABWritingBtn Pressed!")
        listener?.pressedWritingBtn()
    }
    
    @objc
    func pressedMenualBtn() {
        print("메뉴얼 버튼 눌렀니?")
        listener?.pressedMenualTitleBtn()
    }
    
    @objc
    func pressedDateFilterBtn() {
        print("pressedLightCalenderBtn")
        listener?.pressedDateFilterBtn()
    }
    
    @objc
    func pressedFilterBtn() {
        print("pressedFilterBtn")
        listener?.pressedFilterBtn()
    }
    
    @objc
    func pressedFilterResetBtn() {
        print("DiaryHome :: filterReset!!")
        listener?.pressedFilterResetBtn()
    }
    
    @objc
    func pressedScrollToTopFAB() {
        print("DiaryHome :: pressedScrollToTopFAB!!")
        myMenualTableView.setContentOffset(.zero, animated: true)
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
            isDraggingRelay.accept(true)
            attachTopMyMenualTitleView(scrollView)

            DispatchQueue.main.async {
                let scrollIndicator = scrollView.subviews.last!
                scrollIndicator.backgroundColor = .red
                
                self.indicatorView.snp.remakeConstraints { make in
                    make.trailing.equalToSuperview().inset(16)
                    make.centerY.equalTo(scrollIndicator)
                }
            }
        }
    }
    
    // 스크롤시 상단에 titleView가 고정되도록
    func attachTopMyMenualTitleView(_ scrollView: UIScrollView) {
        guard let tableCollectionViewTag = TableCollectionViewTag(rawValue: scrollView.tag) else { return }
        // myMenualTableView일때만 작동하도록
        if case .MyMenualTableView = tableCollectionViewTag {
            print("DiaryHome :: contents offset = \(scrollView.contentOffset.y)")
            let offset = scrollView.contentOffset.y
            // TitleView를 넘어서 스크롤할 경우
            if offset > 155 {
                print("DiaryHome :: contents > 155")
                setFABMode(isEnabled: true)
                myMenualTitleView.AppShadow(.shadow_6)
                myMenualTitleView.backgroundColor = Colors.background
                myMenualTitleView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview()
                    make.width.equalToSuperview()
                    make.top.equalTo(naviView.snp.bottom)
                    make.height.equalTo(55)
                }
            } else {
                print("DiaryHome :: contents <= 155")
                setFABMode(isEnabled: false)
                myMenualTitleView.AppShadow(.shadow_0)
                myMenualTitleView.backgroundColor = .clear
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
        isDraggingRelay.accept(false)
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
        return 34
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilteredRelay.value {
            guard let monthMenualCount = filteredCellsectionNumberDic2[section] else { return 0 }
            print("monthMenualCount = \(monthMenualCount)")

            return monthMenualCount
        } else {
            guard let monthMenualCount = cellsectionNumberDic2[section] else { return 0 }

            print("monthMenualCount = \(monthMenualCount)")

            return monthMenualCount
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFilteredRelay.value {
            print("filteredSectionNameDic.count = \(filteredSectionNameDic.count), \(filteredSectionNameDic)")
            return filteredSectionNameDic.count
        } else {
            return sectionNameDic.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let defaultCell = UITableViewCell()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return defaultCell }
        

        cell.backgroundColor = .clear

        print("cell, ------------------")
        let index: Int = indexPath.row
        let section: Int = indexPath.section
        print("cell, section!! = \(section), indexPath = \(indexPath), index = \(index), !!? \(sectionNameDic[section])")
        // guard let data = myMenualArr[safe: index] else { return UITableViewCell() }
        var data: DiaryModel?
        
        var sectionName: String = ""
        if self.isFilteredRelay.value {
            guard let _sectionName = filteredSectionNameDic[section] else { return defaultCell }
            sectionName = _sectionName
        } else {
            guard let _sectionName = sectionNameDic[section] else { return defaultCell }
            sectionName = _sectionName
        }
        // guard let sectionName = sectionNameDic[section] else { return defaultCell }
        
        // 연도 찾기
        // 2022, 2023 등 Year Parsing
        let yearRange = NSRange(sectionName.startIndex..<sectionName.index(sectionName.startIndex, offsetBy: 4), in: sectionName)
        let year = (sectionName as NSString).substring(with: yearRange)
        
        // 달 찾기
        // AUG, SEP 등 Month Parsing
        let monthRange = NSRange(sectionName.index(sectionName.startIndex, offsetBy: 4)..<sectionName.index(sectionName.startIndex, offsetBy: 7), in: sectionName)
        let month = (sectionName as NSString).substring(with: monthRange)
        print("cell, year = \(year), month = \(month)")
        
        var diaryYearModelArr: [DiaryYearModel] = []
        if self.isFilteredRelay.value {
            diaryYearModelArr = listener?.filteredDiaryMonthSetRelay.value ?? []
        } else {
            diaryYearModelArr = listener?.diaryMonthSetRelay.value ?? []
        }

        for diaryYearModel in diaryYearModelArr {
            if diaryYearModel.year.description != year { continue }
            print("cell, diaryYearmodel과 같은 year을 찾았습니다! = \(year)")
            guard let diaryModelData: [DiaryModel] = diaryYearModel.months?.getMenualArr(MM: month) else { return defaultCell }

            print("cell, diaryModelData를 찾았습니다. = \(diaryModelData)")
            data = diaryModelData[safe: index]
            
        }
        
        guard let data = data else { return defaultCell }
        
        var sectionNumber: Int = 0
        if self.isFilteredRelay.value {
            guard let _sectionNumber: Int = filteredCellsectionNumberDic[data.getSectionName()] else { return defaultCell }
            sectionNumber = _sectionNumber
        } else {
            guard let _sectionNumber: Int = cellsectionNumberDic[data.getSectionName()] else { return defaultCell }
            sectionNumber = _sectionNumber
        }
        // let sectionNumber: Int = cellsectionNumberDic[data.getSectionName()]

        print("cell, sectionNumber = \(sectionNumber), section = \(section)")
        
        if data.isHide {
            cell.listType = .hide
        } else {
            if let image = data.originalImage {
                cell.listType = .textAndImage
                cell.image = image
            } else {
                cell.listType = .normal
            }
        }
        
        cell.title = data.title
        cell.date = data.createdAt.toString()
        cell.time = data.createdAt.toStringHourMin()
        
        let pageCount = "\(data.pageNum)"
        var replies = ""
        if data.replies.count != 0 {
            replies = "\(data.replies.count)"
        }

        cell.pageCount = pageCount
        cell.reviewCount = replies
        cell.testModel = data

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListCell,
              let data = cell.testModel
        else { return }

        print("select! model = \(cell.testModel)")
        
        listener?.pressedDiaryCell(diaryModel: data)
    }
    
    func reloadTableView() {
        print("reloadTableView!")
        // self.isFiltered = isFiltered
        // self.isFilteredRelay.accept(isFiltered)
        myMenualTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionListHeader = SectionListHeaderView()
        sectionListHeader.layer.zPosition = -1

        sectionListHeader.backgroundColor = .clear
        sectionListHeader.title = "2022.999"
        
        print("section, section = \(section)")

        var sectionNameFormat: String = ""
        if self.isFilteredRelay.value {
            guard let _sectionNameFormat = filteredSectionNameDic[section] else { return sectionListHeader }
            sectionNameFormat = _sectionNameFormat
        } else {
            guard let _sectionNameFormat = sectionNameDic[section] else { return sectionListHeader }
            sectionNameFormat = _sectionNameFormat
        }
        
        // guard let sectionNameFormat = sectionNameDic[section] else { return sectionListHeader }
        
        // 연도 변경
        let yearRange = NSRange(sectionNameFormat.startIndex..<sectionNameFormat.index(sectionNameFormat.startIndex, offsetBy: 4), in: sectionNameFormat)
        let year = (sectionNameFormat as NSString).substring(with: yearRange)
        
        // 월로 변경
        let monthRange = NSRange(sectionNameFormat.index(sectionNameFormat.startIndex, offsetBy: 4)..<sectionNameFormat.index(sectionNameFormat.startIndex, offsetBy: 7), in: sectionNameFormat)
        let month = (sectionNameFormat as NSString).substring(with: monthRange).convertMonthName()

        sectionListHeader.title = year + "." + month
        
        return sectionListHeader
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // print("tableView ContentSize = \(self.myMenualTableView.contentSize.height)")
        
//        myMenualTableView.snp.removeConstraints()
//        myMenualTableView.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.width.equalToSuperview()
//            make.bottom.equalToSuperview().inset(myMenualTableView.contentSize.height)
//            make.top.equalTo(divider.snp.bottom).offset(0)
//        }
    }
}

// MARK: - UICollectionView Delegate, Datasource
extension DiaryHomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
            let momentsCollectionViewCount: Int = 5
            self.momentsCollectionViewPagination.numberOfPages = momentsCollectionViewCount
            return momentsCollectionViewCount
        
        default:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        // MomentsCollectionView
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MomentsCell", for: indexPath) as? MomentsCell else { return UICollectionViewCell() }
            
            cell.tagTitle = "TEXT AREA"
            cell.momentsTitle = "타이틀은 최대 20자를 작성할 수 있습니다. 그 이상일 경우 우오아우아"
            
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
            
        default:
            return
        }
    }
}

// MARK: - Test
extension DiaryHomeViewController: DialogDelegate {
    func action(titleText: String) {
        print("액션마")
    }
    
    func exit(titleText: String) {
        print("나감마")
    }
}

// MARK: - Filter
extension DiaryHomeViewController {
    func setFilterStatus(isFiltered: Bool) {
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

            self.writeBoxBtn.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
            self.writeFAB.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
            self.filterEmptyView.isHidden = true
            self.myMenualTableView.reloadData()
        }
    }
}
