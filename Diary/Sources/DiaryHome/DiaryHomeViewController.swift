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
import RxAppState
import RealmSwift
import MenualUtil
import MenualEntity
import DesignSystem
import MessageUI
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

public enum TableCollectionViewTag: Int {
    case MomentsCollectionView = 0
    case MyMenualTableView = 1
}

// MARK: - DiaryHomePresentableListener

public protocol DiaryHomePresentableListener: AnyObject {
    func pressedSearchBtn()
    func pressedMyPageBtn()
    func pressedWritingBtn()
    func pressedDiaryCell(diaryModel: DiaryModelRealm)
    func pressedMomentsCell(momentsItem: MomentsItemRealm)
    func pressedFilterBtn()
    
    func needUpdateAdBanner() -> Int?
    
    var lastPageNumRelay: BehaviorRelay<Int> { get }
    var filterLastPageNumRelay: BehaviorRelay<Int> { get }
    var filteredDiaryDic: BehaviorRelay<DiaryHomeFilteredSectionModel?> { get }
    var diaryDictionary: [String: DiaryHomeSectionModel] { get }
    var onboardingDiarySet: BehaviorRelay<[Int: String]?> { get }
    var momentsRealm: MomentsRealm? { get }

    // Update 내역
    var shouldShowUpdateObservable: Observable<Bool>? { get }
    func showUpdateLogBottomSheet()
}

// MARK: - DiaryHomeViewController

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {

    weak var listener: DiaryHomePresentableListener?
    // 스크롤 위치 저장하는 Dictionary
    var disposeBag = DisposeBag()
    
    let isFilteredRelay = BehaviorRelay<Bool>(value: false)
    var isShowToastDiaryResultRelay = BehaviorRelay<ShowToastType?>(value: nil)

    var isShowAd: Bool = false
    var nativeAd: GADNativeAd?
    private weak var weakToastView: ToastView?
    
    // MARK: - UI 코드
    private let splashView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = Colors.background
    }
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
    
    lazy var filterFAB = FAB(fabType: .primaryFilter, fabStatus: .default_).then {
        $0.actionName = "filter"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedFilterBtn), for: .touchUpInside)
    }
    
    lazy var writeFAB = FAB(fabType: .primary, fabStatus: .default_).then {
        $0.actionName = "write"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
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
    
    lazy var myMenualTitleView = ListHeader(type: .main, rightIconType: .none).then {
        $0.categoryName = "menualTitle"
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.home_title_total_page
    }
    
    lazy var myMenualTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.categoryName = "menual"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.estimatedRowHeight = 72
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 72, right: 0)
        $0.tag = TableCollectionViewTag.MyMenualTableView.rawValue
        $0.separatorStyle = .none
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
            make.top.equalToSuperview().offset(38)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(2)
        }
        
        empty.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(50)
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
    
    private let momentsNoStartView = MomentsNoStartView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    private lazy var adLoader: GADAdLoader = .init(
        adUnitID: ADUtil.diaryHomeUnitID,
        rootViewController: self,
        adTypes: [.native],
        options: []
    )
    
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
        adRequest()
    }
    
    convenience init(screenName3: String) {
        self.init()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        MenualLog.logEventAction("writing_appear")
        actionSplashView()
        askTracking()
    }
    
    func setViews() {
        self.view.backgroundColor = Colors.background
        
        self.view.addSubview(naviView)
        
        self.view.addSubview(myMenualTableView)
        self.view.addSubview(writeFAB)
        self.view.addSubview(filterFAB)
        self.view.addSubview(emptyView)
        self.view.addSubview(momentsEmptyView)
        self.view.addSubview(myMenualTitleView)
        myMenualTableView.tableHeaderView = tableViewHeaderView
        
        tableViewHeaderView.addSubview(momentsCollectionView)
        tableViewHeaderView.addSubview(momentsCollectionViewPagination)
        tableViewHeaderView.addSubview(momentsNoStartView)
        
        naviView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        self.view.bringSubviewToFront(tableViewHeaderView)
        self.view.bringSubviewToFront(writeFAB)
        self.view.bringSubviewToFront(filterFAB)
        self.view.bringSubviewToFront(myMenualTitleView)
        self.view.bringSubviewToFront(naviView)
        
        self.view.addSubview(splashView)
        splashView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
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
            make.height.equalTo(172)
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
        
        momentsNoStartView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
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
            make.top.equalTo(tableViewHeaderView.snp.bottom)
            make.height.equalTo(22)
        }
        
        writeFAB.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.width.height.equalTo(56)
        }
        
        filterFAB.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(114)
            make.width.height.equalTo(56)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(tableViewHeaderView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// 앱. 런치때 부드러운 Init 효과를 위해 Animation
    func actionSplashView() {
        print("DiaryHome :: actionSplashView!")
        UIView.animate(withDuration: 0.25, delay: 0.25) {
            self.splashView.layer.opacity = 0
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
                    if num == -1 || num == 0 {
                        print("DiaryHome :: EmptyView")
                        self.setEmptyView(isEnabled: true)
                    } else {
                        self.setEmptyView(isEnabled: false)
                    }

                    let realNumber: Int = num == -1 || num == 0 ? 0 : num
                    self.myMenualTitleView.pageNumber = realNumber
                    self.reloadTableView()
                }
            })
            .disposed(by: self.disposeBag)
        
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


        listener?.onboardingDiarySet
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if let data = data {
                    self.momentsNoStartView.isHidden = false
                    self.momentsNoStartView.writingDiarySet = data
                    self.tableViewHeaderView.snp.updateConstraints { make in
                        make.height.equalTo(240)
                    }
                    self.view.layoutIfNeeded()
                    self.myMenualTableView.reloadData()
                } else {
                    self.tableViewHeaderView.snp.updateConstraints { make in
                        make.height.equalTo(172)
                    }
                    self.momentsNoStartView.isHidden = true
                }
                self.view.layoutIfNeeded()
                self.myMenualTableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 업데이트 내역
        if let shouldShowUpdateObservable: Observable<Bool> = listener?.shouldShowUpdateObservable {
            rx.viewDidAppear
                .withLatestFrom(shouldShowUpdateObservable)
                .subscribe(onNext: { [weak self] needShowUpdate in
                    guard let self = self else { return }
                    print("DiaryHome :: AppUpdateInfoRepository :: needShowUpdate = \(needShowUpdate)")
                    if needShowUpdate == false { return }
                    listener?.showUpdateLogBottomSheet()
                })
                .disposed(by: disposeBag)
        }
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
    
    func deleteTableViewSection(section: Int) {
        myMenualTableView.beginUpdates()
        let indexSet = IndexSet(integer: section)
        myMenualTableView.deleteSections(indexSet, with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func deleteTableViewRow(section: Int, row: Int) {
        var filteredRow: Int = row
        if let adIndex: Int = listener?.needUpdateAdBanner(),
           section == 0 && isShowAd{
            if row >= adIndex {
                filteredRow = row + 1
            }
        }

        myMenualTableView.beginUpdates()
        myMenualTableView.deleteRows(at: [IndexPath(row: filteredRow, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func reloadTableViewRow(section: Int, row: Int) {
        var filteredRow: Int = row
        if let adIndex: Int = listener?.needUpdateAdBanner(),
           section == 0 && isShowAd{
            if row >= adIndex {
                filteredRow = row + 1
            }
        }

        myMenualTableView.beginUpdates()
        myMenualTableView.reloadRows(at: [IndexPath(row: filteredRow, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func insertTableViewSection() {
        myMenualTableView.beginUpdates()
        let indexSet = IndexSet(integer: myMenualTableView.numberOfSections )
        print("DiaryHome :: indexSet = \(indexSet), myMenualTableView.numberOfSections = \(myMenualTableView.numberOfSections)")
        myMenualTableView.insertSections(indexSet, with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func insertTableViewRow(section: Int, row: Int) {
        var filteredRow: Int = row
        if let adIndex: Int = listener?.needUpdateAdBanner(),
           section == 0 && isShowAd {
            if row >= adIndex {
                filteredRow = row + 1
            }
        }
        
        myMenualTableView.beginUpdates()
        myMenualTableView.insertRows(at: [IndexPath(row: filteredRow, section: section)], with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func insertTableViewRow(section: Int, rows: [Int]) {
        myMenualTableView.beginUpdates()
        let indexPaths = rows.map { IndexPath(item: $0, section: section)}
        myMenualTableView.insertRows(at: indexPaths, with: .automatic)
        myMenualTableView.endUpdates()
    }
    
    func showRestoreSuccessToast() {
        _ = showToast(message: "메뉴얼 가져오기가 완료되었습니다.")
    }
    
    func insertAdBanner(row: Int) {
        myMenualTableView.beginUpdates()
        myMenualTableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
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
        MenualLog.logEventAction(responder: button, parameter: ["type" : "fab"])
    }
    
    @objc
    func pressedMenualBtn(_ button: UIButton) {
        print("메뉴얼 버튼 눌렀니?")
    }
    
    @objc
    func pressedFilterBtn(_ button: UIButton) {
        print("pressedFilterBtn")
        listener?.pressedFilterBtn()
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
            break
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index: Int = indexPath.row
        let section: Int = indexPath.section
        
        if let adIndex = listener?.needUpdateAdBanner(),
           adIndex == index && isShowAd && section == 0 {
            let adDescriptionCount: Int = nativeAd?.body?.count ?? 0
            return adDescriptionCount > 50 ? 115 : 104
        }
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 첫번재 섹션일 경우에는 넓게 안띄움
        if section == 0 {
            return 82
            // return 200
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilteredRelay.value {
            guard let diaryDictionary = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return 0 }
            guard let findDict = diaryDictionary.filter ({ $0.value.sectionIndex == section }).first
            else { return 0 }

            return findDict.value.diaries.count
        } else {
            guard let diaryDictionary = listener?.diaryDictionary else { return 0 }
            guard let findDict = diaryDictionary.filter({ $0.value.sectionIndex == section }).first else { return 0 }
            
            var diaryCount: Int = findDict.value.diaries.count
            findDict.value.diaries.forEach {
                if $0.isInvalidated {
                    diaryCount -= 1
                }
            }
            
            // 광고 로딩이 완료되었을 경우
            // 첫번재 섹션만 +1
            if let _ = listener?.needUpdateAdBanner(),
               isShowAd && section == 0 {
                return diaryCount + 1
            }
            
            return diaryCount
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
        var index: Int = indexPath.row
        var dataIndex: Int = indexPath.row
        let section: Int = indexPath.section
        
        if let adIndex: Int = listener?.needUpdateAdBanner(),
           isShowAd && section == 0 {
            if index >= adIndex {
                dataIndex -= 1
            }
        }

        var dataModel: DiaryModelRealm?
        var nativeAd: GADNativeAd?
        let defaultCell = UITableViewCell()
        
        // 필터 여부에 따라서 참조하는 Cell과 Data 변경
        switch self.isFilteredRelay.value {
        case true:
            guard let diaryDictionry: [String: DiaryHomeSectionModel] = listener?.filteredDiaryDic.value?.diarySectionModelDic else { return defaultCell }
            guard let dataDictionary = diaryDictionry.filter ({ $0.value.sectionIndex == section }).first else { return defaultCell }
            guard let data = dataDictionary.value.diaries[safe: index] else { return defaultCell }
            dataModel = data

        case false:
            guard let diaryDictionry: [String: DiaryHomeSectionModel] = listener?.diaryDictionary else { return defaultCell }
            guard let dataDictionary = diaryDictionry.filter ({ $0.value.sectionIndex == section }).first else { return defaultCell }
            
            // 광고 업로드가 가능한 상황에서는
            // 첫번째 섹션 3번째 인덱스(4번째 셀)에서만 광고 노출
            if let adIndex: Int = listener?.needUpdateAdBanner(),
               isShowAd && section == 0 && index == adIndex {
                guard let data = self.nativeAd else { return defaultCell }
                nativeAd = data
            } else {
                guard let data = dataDictionary.value.diaries[safe: dataIndex] else { return defaultCell }
                dataModel = data
            }
        }
        
        // 광고 셀일 경우
        if let nativeAd = nativeAd {
            cell.listType = .adBodyTextImage
            cell.title = nativeAd.headline ?? "광고"
            cell.image = nativeAd.images?.first?.image ?? UIImage()
            cell.body = nativeAd.body ?? ""
            cell.adText = nativeAd.advertiser ?? "스폰서"
            cell.nativeAd = nativeAd
            return cell
        }
        
        // 광고가 아닐 경우
        guard let dataModel = dataModel else { return UITableViewCell() }
        
              
        if dataModel.isHide {
            cell.listType = .hide
        } else {
            let thumbImageIndex: Int = dataModel.thumbImageIndex
            if let imageData = dataModel.thumbImage,
               let image: UIImage = UIImage(data: imageData) {
                let resizeImageData = UIImage().imageWithImage(sourceImage: image, scaledToWidth: 150)
                cell.listType = .textAndImage
                DispatchQueue.main.async {
                    cell.image = resizeImageData
                }
            } else if let imageData: Data = dataModel.images[safe: thumbImageIndex],
                      let image: UIImage = .init(data: imageData) {
                let resizeImageData = UIImage().imageWithImage(sourceImage: image, scaledToWidth: 150)
                cell.listType = .textAndImage
                DispatchQueue.main.async {
                    cell.image = resizeImageData
                }
            } else {
                cell.image = nil
                cell.listType = .normal
            }
        }
        
        cell.listScreen = .home
        cell.title = dataModel.title
        cell.date = dataModel.createdAt.toString()
        cell.time = dataModel.createdAt.toStringHourMin()
        cell.body = ""
        
        let pageCount = "\(dataModel.pageNum)"
        var replies = ""
        if dataModel.replies.count != 0 {
            replies = "\(dataModel.replies.count)"
        }

        cell.pageCount = pageCount
        cell.reviewCount = replies
        cell.testModel = dataModel
        
        cell.actionName = "cell"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
        // 광고 셀일 경우
        if cell.listType == .adBodyTextImage {
            print("광고입니다.")
            return
        }
        
        // 메뉴얼 셀일 경우
        guard let data = cell.testModel else { return }

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
            let onboardingIsClear: Bool = listener?.momentsRealm?.onboardingIsClear ?? false
            // let isClearOnboarding: Bool = listener?.onboardingDiarySet
            // 초기에는 Realm도 설정되어 있지 않으므로 따로 설정
            guard let momentsCount = listener?.momentsRealm?.itemsArr.count else {
                return  0
            }
            print("DiaryHome :: momentsCount = \(momentsCount)")

            if momentsCount == 0 && onboardingIsClear {
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
            
            cell.tagTitle = "MOMENTS"
            cell.momentsTitle = data.title
            cell.icon = data.icon
            
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
        switch isFiltered {
        case true:
            filterFAB.isFiltered = .enabled
            let lastPageNum: Int = self.listener?.filterLastPageNumRelay.value ?? 0
            myMenualTitleView.pageNumber = lastPageNum
            
        case false:
            filterFAB.isFiltered = .disabled
            
            let lastPageNum: Int = self.listener?.lastPageNumRelay.value ?? 0
            myMenualTitleView.pageNumber = lastPageNum
            reloadTableView()
        }
    }
}

// MARK: - Toast
extension DiaryHomeViewController {
    func showToastDiaryResult(mode: ShowToastType) {
        print("DiaryHome :: showToastDiaryResult!")
        switch mode {
        case .writing:
            let toastView = showToast(message: MenualString.home_toast_writing)
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "write"])

        case .edit:
            let toastView = showToast(message: "메뉴얼 등록이 수정되었습니다.")
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "edit"])
            
        case .delete:
            let toastView = showToast(message: MenualString.home_toast_delete)
            self.weakToastView = toastView
            MenualLog.logEventAction(responder: toastView, parameter: ["type": "delete"])
            
        case .none:
            break
        }

        isShowToastDiaryResultRelay.accept(nil)
    }
}

// MARK: - Review
extension DiaryHomeViewController: MFMailComposeViewControllerDelegate {
    /// 리뷰 팝업에서 건의하기 버튼을 눌렀을 경우
    func presentMailVC() {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             Q. 메뉴얼을 사용해주셔서 감사합니다. 어떤 주제의 건의사항 인가요? ( 기능제안, 오류제보, 기타 등등 )

                             :

                             Q. 내용을 간단히 설명해 주세요. 사진을 첨부해주셔도 좋습니다.

                             :

                             건의해주셔서 감사합니다. 빠른 시일 내 조치하여 업데이트 하도록 하겠습니다.
                             
                             -------------------
                             
                             Device Model : \(DeviceUtil.getDeviceIdentifier())
                             Device OS : \(UIDevice.current.systemVersion)
                             App Version : \(DeviceUtil.getCurrentVersion())
                             
                             -------------------
                             """
            
            composeViewController.setToRecipients(["jjikkyu@naver.com"])
            composeViewController.setSubject("<메뉴얼> 건의하기")
            composeViewController.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeViewController, animated: true, completion: nil)
        } else {
            print("메일 보내기 실패")
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
            let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
                // 앱스토어로 이동하기(Mail)
                if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            sendMailErrorAlert.addAction(goAppStoreAction)
            sendMailErrorAlert.addAction(cancleAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate / BackSwipe Bug
extension DiaryHomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - Admob

extension DiaryHomeViewController {
    func askTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // 사용자가 권한을 허용한 경우, IDFA 사용 가능
                let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                print("adsupport : \(idfaString)")
                // IDFA 값을 사용하거나 저장하거나 필요한 처리를 진행합니다.
            case .denied:
                // 사용자가 권한을 거부한 경우, IDFA 사용 불가
                // 권한 거부에 따른 대체 로직이나 처리를 수행합니다.
                break
            case .restricted, .notDetermined:
                // 사용자가 권한을 설정하지 않은 경우 또는 제한된 경우, IDFA 사용 불가
                // 대체 로직이나 처리를 수행합니다.
                break
            @unknown default:
                break
            }
        }
    }
}

extension DiaryHomeViewController: GADNativeAdLoaderDelegate, GADNativeAdDelegate {
    // 광고 노출 유저에게 광고를 노출하기 위해서 서버에 요청하는 함수
    func adRequest() {
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Admob :: error \(error)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        if isShowAd { return }
        
        // 광고 업데이트가 가능한 지 체크
        guard let needUpdateIndex: Int = listener?.needUpdateAdBanner() else {
            return
        }
        
        isShowAd = true
        self.nativeAd = nativeAd
        nativeAd.delegate = self
        insertAdBanner(row: needUpdateIndex)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("Admob :: click!")
    }
}
