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

    func reloadTableViewRow(section: Int, row: Int)
    func insertTableViewRow(section: Int, row: Int)
    func deleteTableViewRow(section: Int, row: Int)
    
    func insertTableViewSection()
    func deleteTableViewSection(section: Int)
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
    var filteredDiaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]>
    let filteredDiaryCountRelay = BehaviorRelay<Int>(value: -1)
    
    let filteredWeatherArrRelay = BehaviorRelay<[Weather]>(value: [])
    let filteredPlaceArrRelay = BehaviorRelay<[Place]>(value: [])
    
    var notificationToken: NotificationToken?
    
    var diaryRealmArr: Results<DiaryModelRealm>?
    var diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()

    init(
        presenter: DiaryHomePresentable,
        dependency: DiaryHomeInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
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
                    let lastPageNum = model.filter { $0.isDeleted == false }
                        .sorted { $0.createdAt > $1.createdAt }
                        .first?.pageNum ?? 0
                    self.lastPageNumRelay.accept(lastPageNum)
                    
                    // 초기에는 필터 적용이 아니므로 false 전달
                    self.presenter.isFilteredRelay.accept(false)

                    // Set로 중복되지 않도록, Section Header Name 추가 (2022.12, 2022.11 등)
                    var section = Set<String>()
                    let newModel = model.filter{ $0.isDeleted == false }
                    newModel.forEach { section.insert($0.createdAt.toStringWithYYYYMM()) }
                    //
                    var arraySerction = Array(section)
                    arraySerction.sort { $0 > $1 }
                    arraySerction.enumerated().forEach { (index: Int, sectioName: String) in
                        self.diaryDictionary[sectioName] = DiaryHomeSectionModel(sectionName: sectioName, sectionIndex: index, diaries: [])
                    }
                    let sortedModel: [DiaryModelRealm] = newModel.sorted(by: { $0.createdAt > $1.createdAt })
                    for diary in sortedModel {
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()
                        self.diaryDictionary[sectionName]?.diaries.append(DiaryModel(diary))
                    }
                    print("DiaryHome :: diaryDictionary = \(self.diaryDictionary)")
                    print("DiaryHome :: sectionSet = \(section)")

                    self.presenter.reloadTableView()
                    
                case .update(let model, _, let insertions, let modifications):
                    print("DiaryHome :: update! = \(model)")
                    if insertions.count > 0 {
                        guard let insertionsRow: Int = insertions.first else { return }
                        print("DiaryHome :: realmObserve = insertion = \(insertions)")
                        let diary: DiaryModelRealm = model[insertionsRow]
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()

                        // 글이 하나도 없을 경우에는 sectionIndex 0에 작성될 수 있도록
                        let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex ?? 0
                        if self.diaryDictionary[sectionName] == nil {
                            print("DiaryHome :: test! = nil입니다!")
                            self.diaryDictionary[sectionName] = DiaryHomeSectionModel(sectionName: sectionName, sectionIndex: 0, diaries: [])
                            self.presenter.insertTableViewSection()
                        }

                        // 전체 PageNum 추려내기
                        let lastPageNum = model.filter { $0.isDeleted == false }
                            .sorted { $0.createdAt > $1.createdAt }
                            .first?.pageNum ?? 0
                        
                        let lastPageNumTest = self.diaryDictionary[sectionName]?.diaries.filter { $0.isDeleted == false }.first?.pageNum
                        
                        print("DiaryHome :: test! = \(lastPageNum), \(lastPageNumTest)")
                        self.lastPageNumRelay.accept(lastPageNum)
                        

                        self.diaryDictionary[sectionName]?.diaries.insert(DiaryModel(diary), at: 0)
                        print("DiaryHome :: test! = \(self.diaryDictionary[sectionName]?.diaries)")
                        self.presenter.insertTableViewRow(section: sectionIndex, row: 0)
                    }
                        
                    if modifications.count > 0 {
                        guard let modificationsRow: Int = modifications.first else { return }
                        print("DiaryHome :: realmObserve = modifications = \(modifications)")
                        let diary: DiaryModelRealm = model[modificationsRow]
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()

                        guard let diaries: [DiaryModel] = self.diaryDictionary[sectionName]?.diaries,
                              let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex,
                              let row: Int = diaries.indices.filter ({ diaries[$0].uuid == diary.uuid }).first
                        else { return }
                        
                        // 삭제일때
                        if diary.isDeleted == true {
                            // 전체 PageNum 추려내기
                            let lastPageNum = model.filter { $0.isDeleted == false }
                                .sorted { $0.createdAt > $1.createdAt }
                                .first?.pageNum ?? 0

                            self.lastPageNumRelay.accept(lastPageNum)
                            self.diaryDictionary[sectionName]?.diaries.remove(at: row)
                            print("DiaryHome :: delete! = \(self.diaryDictionary)")
                            self.presenter.deleteTableViewRow(section: sectionIndex, row: row)
                            
                            if let diaryCount: Int = self.diaryDictionary[sectionName]?.diaries.count,
                               diaryCount == 0 {
                                print("DiaryHome :: 지워야할 것 같은걸")
                                let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex ?? 0
                                self.diaryDictionary[sectionName] = nil
                                self.presenter.deleteTableViewSection(section: sectionIndex)
                            }
                        }
                        // 수정일때
                        else {
                            self.diaryDictionary[sectionName]?.diaries[row] = DiaryModel(diary)
                            self.presenter.reloadTableViewRow(section: sectionIndex, row: row)
                        }
                    }
                        
                    case .error(let error):
                        fatalError("\(error)")
                }
            }
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
