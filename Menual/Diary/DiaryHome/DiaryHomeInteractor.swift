//
//  DiaryHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import RealmSwift
import RxRelay

protocol DiaryHomeRouting: ViewableRouting {
    func attachMyPage()
    func detachMyPage(isOnlyDetach: Bool)
    func attachDiarySearch()
    func detachDiarySearch(isOnlyDetach: Bool)
    func attachDiaryMoments()
    func detachDiaryMoments()
    func attachDiaryWriting(page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    func attachDiaryDetail(model: DiaryModel)
    func detachDiaryDetail(isOnlyDetach: Bool)
    func attachDesignSystem()
    func detachDesignSystem(isOnlyDetach: Bool)
    func attachBottomSheet(type: MenualBottomSheetType)
    func detachBottomSheet()
}

protocol DiaryHomePresentable: Presentable {
    var listener: DiaryHomePresentableListener? { get set }
    var isFilteredRelay: BehaviorRelay<Bool> { get }
    var isShowToastDiaryResultRelay: BehaviorRelay<DiaryHomeViewController.ShowToastType?> { get }
    
    func reloadTableView()
    func scrollToDateFilter(yearDateFormatString: String)
    func deleteRow(index: Int)
}

protocol DiaryHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

protocol DiaryHomeInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryHomeInteractor: PresentableInteractor<DiaryHomePresentable>, DiaryHomeInteractable, DiaryHomePresentableListener, AdaptivePresentationControllerDelegate {

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy

    weak var router: DiaryHomeRouting?
    weak var listener: DiaryHomeListener?
    private let dependency: DiaryHomeInteractorDependency
    private var disposebag: DisposeBag

    var lastPageNumRelay = BehaviorRelay<Int>(value: 0)
    var diaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]> = BehaviorRelay<[DiaryYearModel]>(value: [])
    var filteredDiaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]>
    let filteredDiaryCountRelay = BehaviorRelay<Int>(value: -1)
    
    let filteredWeatherArrRelay = BehaviorRelay<[Weather]>(value: [])
    let filteredPlaceArrRelay = BehaviorRelay<[Place]>(value: [])
    
    var notificationToken: NotificationToken?
    var diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()
//    var filteredWeatherArr: [Weather] = []
//    var filteredPlaceArr: [Place] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryHomePresentable,
        dependency: DiaryHomeInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        // self.diaryMonthSetRelay = dependency.diaryRepository.diaryMonthDic
        self.filteredDiaryMonthSetRelay = dependency.diaryRepository.filteredMonthDic
        super.init(presenter: presenter)
        presenter.listener = self
        self.presentationDelegateProxy.delegate = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        print("DiaryHomeInteractor :: Bind!")
        dependency.diaryRepository
            .filteredMonthDic
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] diaryArr in
                guard let self = self else { return }
                print("filteredDiaryString 구독 중!, diary = \(diaryArr)")
                print("<- reloadTableView")

                var menualCount: Int = 0
                for month in diaryArr {
                    menualCount += month.months?.allCount ?? 0
                }
                
                self.lastPageNumRelay.accept(menualCount)
                self.presenter.isFilteredRelay.accept(true)
                self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)
        
        guard let realm = Realm.safeInit() else { return }
        notificationToken = realm.objects(DiaryModelRealm.self)
            .observe { result in
                switch result {
                case .initial(let model):
                    print("DiaryHome :: realmObserve = initial! = \(model)")
                    self.diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()
                    
                    // 전체 PageNum 추려내기
                    let lastPageNum = model.sorted { $0.createdAt > $1.createdAt }.first?.pageNum ?? 0
                    self.lastPageNumRelay.accept(lastPageNum)
                    
                    // 초기에는 필터 적용이 아니므로 false 전달
                    self.presenter.isFilteredRelay.accept(false)

                    // Set로 중복되지 않도록, Section Header Name 추가 (2022.12, 2022.11 등)
                    var section = Set<String>()
                    model.forEach { section.insert($0.createdAt.toStringWithYYYYMM()) }
                    //
                    var arraySerction = Array(section)
                    arraySerction.sort { $0 > $1 }
                    arraySerction.enumerated().forEach { (index: Int, sectioName: String) in
                        self.diaryDictionary[sectioName] = DiaryHomeSectionModel(sectionName: sectioName, sectionIndex: index, diaries: [])
                    }
                    for diary in model {
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()
                        self.diaryDictionary[sectionName]?.diaries.append(DiaryModel(diary))
                    }
                    print("DiaryHome :: diaryDictionary = \(self.diaryDictionary)")
                    print("DiaryHome :: sectionSet = \(section)")

                    self.presenter.reloadTableView()
                    
                case .update(let model, let deletions, let insertions, let modifications):
                    print("DiaryHome :: update! = \(model)")
                    if deletions.count > 0 {
                        guard let deletionsRow: Int = deletions.first else { return }
                    }
                    
                    if insertions.count > 0 {
                        guard let insertionsRow: Int = insertions.first else { return }
                        print("DiaryHome :: realmObserve = insertion = \(insertions)")
                    }
                        
                    if modifications.count > 0 {
                        guard let modificationsRow: Int = modifications.first else { return }
                        print("DiaryHome :: realmObserve = modifications = \(modifications)")
                    }
                        
                    case .error(let error):
                        fatalError("\(error)")
                }
            }
        
        /*
        notificationToken = realm.objects(DiaryModelRealm.self)
            .observe { result in
                switch result {
                case .initial(let model):
                    print("DiaryHome :: realmObserve = initial! = \(model)")
                    var diaryYearModels: [DiaryYearModel] = []
                    
                    // 연도별 Diary 세팅
                    var beforeYear: String = "0"
                    for diary in model {
                        let curYear = diary.createdAt.toStringWithYYYY() // 2021, 2022 등으로 변경
                        if beforeYear == curYear { continue }
                        beforeYear = curYear
                        
                        diaryYearModels.append(DiaryYearModel(year: Int(curYear) ?? 0, months: DiaryMonthModel()))
                    }
                    
                    // 달별 Diary 세팅
                    for index in diaryYearModels.indices {
                        // 같은 연도인 Diary만 Filter
                        let sortedDiaryModelResults = model.filter { $0.createdAt.toStringWithYYYY() == diaryYearModels[index].year.description }
                        
                        for diary in sortedDiaryModelResults {
                            let diaryMM = diary.createdAt.toStringWithMM() // 01, 02 등으로 변경
                            let diaryModel = DiaryModel(diary)

                            diaryYearModels[index].months?.updateCount(MM: diaryMM, diary: diaryModel)
                            // diaryYearModels[index].months?.addDiary(diary: diary)
                            diaryYearModels[index].months?.updateAllCount()
                        }

                        diaryYearModels[index].months?.sortDiary()
                    }
                    
                    let diaryYearSortedModels = diaryYearModels.sorted { $0.year > $1.year }
                    
                    print("DiaryHome :: \(diaryYearModels)")
                    self.diaryMonthSetRelay.accept(diaryYearSortedModels)
                    self.presenter.isFilteredRelay.accept(false)
                    self.presenter.reloadTableView()

                case .update(let model, let deletions, let insertions, let modifications):
                    print("DiaryHome :: update! = \(model)")
                    if deletions.count > 0 {
                        guard let deletionsRow: Int = deletions.first else { return }
                        self.presenter.deleteRow(index: deletionsRow)
                        let count = self.dependency.diaryRepository.diaryString.value.count
                        let t = self.dependency.diaryRepository.diaryString.value[count - (deletionsRow + 1)]
                        print("DiaryHome :: realmObserve = t.title = \(t.title)")
                        print("DiaryHome :: realmObserve = deleteRow = \(deletions)")
                    }

                    if insertions.count > 0 {
                        guard let insertionsRow: Int = insertions.first else { return }
                        let diaryModelRealm: DiaryModelRealm = model[insertionsRow]
                        let diaryModel: DiaryModel = DiaryModel(diaryModelRealm)
                        print("DiaryHome :: realmObserve = insertion = \(insertions)")
                        
                        let year: Int = Int(diaryModel.createdAt.toStringWithYYYY()) ?? 0
                        let month: String = diaryModel.createdAt.toStringWithMonthEngName().lowercased()
                        
                        var findYearIndex: Int = 0
                        guard let yearModel = self.diaryMonthSetRelay.value.enumerated().filter({ (index: Int, element: DiaryYearModel) -> Bool in
                            findYearIndex = index
                            return element.year == year
                        }).first else { return }
                        
                        guard let diaryModelArr: [DiaryModel] = yearModel.element.months?["\(month)Diary"] as? [DiaryModel] else { return }
                        
                        var newDiaryModelArr: [DiaryModel] = diaryModelArr
                        newDiaryModelArr.append(diaryModel)
                        newDiaryModelArr.sort { $0.createdAt > $1.createdAt }
                        
                        var monthSetRelayValue = self.diaryMonthSetRelay.value
                        monthSetRelayValue[findYearIndex].months?.setMenualArr(MM: month, diaryModel: newDiaryModelArr)
                        
                        self.diaryMonthSetRelay.accept(monthSetRelayValue)
                        DispatchQueue.main.async {
                            self.presenter.reloadTableView()
                        }
                    }

                    if modifications.count > 0 {
                        guard let modificationsRow: Int = modifications.first else { return }
                        let diaryModelRealm: DiaryModelRealm = model[modificationsRow]
                        let diaryModel: DiaryModel = DiaryModel(diaryModelRealm)
                        
                        let year: Int = Int(diaryModel.createdAt.toStringWithYYYY()) ?? 0
                        let month: String = diaryModel.createdAt.toStringWithMonthEngName().lowercased()
                        
                        var findYearIndex: Int = 0
                        guard let yearModel = self.diaryMonthSetRelay.value.enumerated().filter({ (index: Int, element: DiaryYearModel) -> Bool in
                            findYearIndex = index
                            return element.year == year
                        }).first else { return }

                        
                        guard let diaryModelArr: [DiaryModel] = yearModel.element.months?["\(month)Diary"] as? [DiaryModel] else { return }
                        
                        var findIndex: Int = 0
                        let _ = diaryModelArr.enumerated().filter { (index: Int, element: DiaryModel) -> Bool in
                            findIndex = index
                            return element.uuid == diaryModel.uuid
                        }
                        
                        guard let diaryModelArr: [DiaryModel] = self.diaryMonthSetRelay.value[safe: findYearIndex]?.months?["\(month)Diary"] as? [DiaryModel] else { return }
                        
                        var newDiaryModelArr = diaryModelArr
                        newDiaryModelArr[findIndex] = diaryModel
                        
                        var monthSetRelayValue = self.diaryMonthSetRelay.value
                        monthSetRelayValue[findYearIndex].months?.setMenualArr(MM: month, diaryModel: newDiaryModelArr)
                        
                        self.diaryMonthSetRelay.accept(monthSetRelayValue)
                        DispatchQueue.main.async {
                            self.presenter.reloadTableView()
                        }
                         
                        print("DiaryHome :: realmObserve = modifications = \(modifications)")
                    }

                case .error(let error):
                    fatalError("\(error)")
                }
            }
         */
    }
    
    func getMyMenualCount() -> Int {
        return dependency.diaryRepository.diaryString.value.count
    }
    
    func getMyMenualArr() -> [DiaryModel] {
        return dependency.diaryRepository.diaryString.value
    }
    
    // AdaptivePresentationControllerDelegate, Drag로 뷰를 Dismiss 시킬경우에 호출됨
    func presentationControllerDidDismiss() {
        print("!!")
    }
    
    // MARK: - MyPage (ProfileHome) 관련 함수
    func pressedMyPageBtn() {
        print("DiaryHomeInteractor :: pressedMyPageBtn!")
        router?.attachMyPage()
    }
    
    func profileHomePressedBackBtn(isOnlyDetach: Bool) {
        print("DiaryHomeInteractor :: profileHomePressedBackBtn!")
        router?.detachMyPage(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - Diary Search (검색화면) 관련 함수
    func pressedSearchBtn() {
        print("DiaryHomeInteractor :: pressedSearchBtn!")
        router?.attachDiarySearch()
    }
    
    func diarySearchPressedBackBtn(isOnlyDetach: Bool) {
        print("DiaryHomeInteractor :: diarySearchPressedBackBtn!")
        router?.detachDiarySearch(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - Moments 관련 함수
    func pressedMomentsTitleBtn() {
        print("DiaryHomeInteractor :: pressedMomentsTitleBtn!")
        router?.attachDiaryMoments()
    }
    
    func pressedMomentsMoreBtn() {
        print("DiaryHomeInteractor :: pressedMomentsMoreBtn!")
        router?.attachDiaryMoments()
    }
    
    func diaryMomentsPressedBackBtn() {
        print("DiaryHomeInteractor :: diaryMomentsPressedBackBtn!")
        router?.detachDiaryMoments()
    }
    
    // MARK: - Diary Writing 관련 함수
    func pressedWritingBtn() {
        print("DiaryHomeInteractor :: pressedWritingBtn!")
        router?.attachDiaryWriting(page: lastPageNumRelay.value + 1)
    }
    
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType) {
        if isNeedToast {
            presenter.isShowToastDiaryResultRelay.accept(mode)
        }

        router?.detachDiaryWriting(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - Diary detaill 관련 함수
    func pressedDiaryCell(diaryModel: DiaryModel) {
        
        router?.attachDiaryDetail(model: diaryModel)

//        var updateModel: DiaryModel?
        
//        if isFiltered {
//            print("필터 클릭하면 작동되도록 하자")
//
//        } else {
//            guard let model = dependency.diaryRepository
//                .diaryString.value[safe: index] else { return }
//
//            updateModel = DiaryModel(uuid: model.uuid,
//                                         pageNum: model.pageNum,
//                                         title: model.title,
//                                         weather: model.weather,
//                                         place: model.place,
//                                         description: model.description,
//                                         image: model.image,
//                                         readCount: model.readCount + 1,
//                                         createdAt: model.createdAt,
//                                         replies: model.replies,
//                                         isDeleted: model.isDeleted,
//                                         isHide: model.isHide
//            )
//        }
//
//        guard let updateModel = updateModel else {
//            return
//        }
//
//        dependency.diaryRepository
//            .updateDiary(info: updateModel)
//        router?.attachDiaryDetail(model: updateModel)
    }
    //ㅅㅏㄹㅏㅇㅎㅐ i luv u ㅅㅏㄹㅏㅇㅅㅏㄹㅏㅇㅎㅐ ㅅㅏㄹ6ㅎㅐ jjikkyu
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryDetail(isOnlyDetach: isOnlyDetach)
    }
    
    func diaryDeleteNeedToast(isNeedToast: Bool) {
        print("DiaryHome :: diaryDeleteNeedToast = \(isNeedToast)")
        presenter.isShowToastDiaryResultRelay.accept(.delete)
    }

    // MARK: - Menual Title Btn을 눌렀을때 Action
    func pressedMenualTitleBtn() {
        router?.attachDesignSystem()
    }
    
    func designSystemPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDesignSystem(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - Diary Bottom Sheet
    func diaryBottomSheetPressedCloseBtn() {
        print("diaryBottomSheetPressedCloseBtn")
        router?.detachBottomSheet()
    }
    
    func pressedFilterBtn() {
        router?.attachBottomSheet(type: .filter)
    }
    
    func pressedDateFilterBtn() {
        router?.attachBottomSheet(type: .dateFilter)
        
//        if filteredDateRelay.value == nil {
//            filteredDateRelay.accept(Date())
//        }
    }
    
    // filterComponenetView
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place]) {
        print("diaryHome :: \(weatherArr), \(placeArr)")
        if weatherArr.count == 0 && placeArr.count == 0 {
            print("diaryHome :: Interactor -> isFiltered = false")
//            filteredWeatherArrRelay.accept([])
//            filteredPlaceArrRelay.accept([])
            filteredDiaryCountRelay.accept(-1)
        } else if weatherArr.count > 0 || placeArr.count > 0 {
            print("diaryHome :: Interactor -> isFiltered = true")
            // filteredWeatherArrRelay.accept(weatherArr)
            // filteredPlaceArrRelay.accept(placeArr)
            
            let filterCount: Int = dependency.diaryRepository
                .filterDiary(weatherTypes: weatherArr,
                             placeTypes: placeArr,
                             isOnlyFilterCount: true
                )
            filteredDiaryCountRelay.accept(filterCount)
        }
    }
    
    // 필터를 적용하고 확인 버튼을 눌렀을 경우 최종적으로 필터 적용
    func filterWithWeatherPlacePressedFilterBtn() {
        print("diaryHomeInteractor :: filterWithWeatherPlacePressedFilterBtn!")

        if filteredWeatherArrRelay.value.count == 0 && filteredPlaceArrRelay.value.count == 0 {
            presenter.isFilteredRelay.accept(false)
            dependency.diaryRepository.fetch()
        } else {
            presenter.isFilteredRelay.accept(true)
            let _ = dependency.diaryRepository
                .filterDiary(weatherTypes: filteredWeatherArrRelay.value,
                             placeTypes: filteredPlaceArrRelay.value,
                             isOnlyFilterCount: false
                )
        }
        router?.detachBottomSheet()
    }
    
    // interactor에 저장된 필터 목록을 제거하고, repository에서 새로 fetch
    func pressedFilterResetBtn() {
        print("diaryHome :: Inetactor -> filterReset!")
        filteredWeatherArrRelay.accept([])
        filteredPlaceArrRelay.accept([])
        
        presenter.isFilteredRelay.accept(false)
        // filteredDateRelay.accept(nil)
        filteredDiaryCountRelay.accept(-1)
        dependency.diaryRepository
            .fetch()
    }
    
    // DateFilter
    func filterDatePressedFilterBtn(yearDateFormatString: String) {
        print("DiaryHome :: filterBtn!, yearDateFormatString = \(yearDateFormatString)")
        // guard let date = filteredDateRelay.value else { return }

        // presenter.isFilteredRelay.accept(true)
//        _ = dependency.diaryRepository
//            .filterDiary(date: date, isOnlyFilterCount: false)
        // filteredDateRelay.accept(nil)
        presenter.scrollToDateFilter(yearDateFormatString: yearDateFormatString)
        router?.detachBottomSheet()
    }
}


// MARK: - 미사용
extension DiaryHomeInteractor {
    func reminderCompViewshowToast(isEding: Bool) { }
}

protocol PropertyReflectable { }

extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        for child in m.children {
            if child.label == key { return child.value }
        }
        return nil
    }
}
