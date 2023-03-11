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
import Foundation
import MenualEntity
import MenualUtil
import MenualRepository
import DiaryBottomSheet

public protocol DiaryHomeRouting: ViewableRouting {
    func attachMyPage()
    func detachMyPage(isOnlyDetach: Bool, isAnimated: Bool)
    func attachDiarySearch()
    func detachDiarySearch(isOnlyDetach: Bool)
    func attachDiaryWriting(page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    func attachDiaryDetail(model: DiaryModelRealm)
    func detachDiaryDetail(isOnlyDetach: Bool)
    func attachBottomSheet(type: MenualBottomSheetType)
    func detachBottomSheet()
}

public protocol DiaryHomePresentable: Presentable {
    var listener: DiaryHomePresentableListener? { get set }
    var isFilteredRelay: BehaviorRelay<Bool> { get }
    var isShowToastDiaryResultRelay: BehaviorRelay<ShowToastType?> { get }
    
    func reloadTableView()
    func reloadCollectionView()
    func scrollToDateFilter(yearDateFormatString: String)

    func reloadTableViewRow(section: Int, row: Int)
    func insertTableViewRow(section: Int, row: Int)
    func insertTableViewRow(section: Int, rows: [Int])
    func deleteTableViewRow(section: Int, row: Int)
    
    func insertTableViewSection()
    func deleteTableViewSection(section: Int)
    
    func showRestoreSuccessToast()
}

public protocol DiaryHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

public protocol DiaryHomeInteractorDependency {
    var diaryUUIDRelay: BehaviorRelay<String> { get }
    var diaryRepository: DiaryRepository { get }
    var momentsRepository: MomentsRepository { get }
}

final class DiaryHomeInteractor: PresentableInteractor<DiaryHomePresentable>, DiaryHomeInteractable, DiaryHomePresentableListener, AdaptivePresentationControllerDelegate {

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy

    weak var router: DiaryHomeRouting?
    weak var listener: DiaryHomeListener?
    private let dependency: DiaryHomeInteractorDependency
    private var disposebag: DisposeBag

    var lastPageNumRelay = BehaviorRelay<Int>(value: 0)
    var filteredDiaryDic: BehaviorRelay<DiaryHomeFilteredSectionModel?>
    let filteredDiaryCountRelay = BehaviorRelay<Int>(value: -1)
    
    let filterResetBtnRelay = BehaviorRelay<Bool>(value: false)
    let filteredWeatherArrRelay = BehaviorRelay<[Weather]>(value: [])
    let filteredPlaceArrRelay = BehaviorRelay<[Place]>(value: [])
    
    var notificationToken: NotificationToken? // DiaryModelRealm Noti
    var notificationTokenMoments: NotificationToken? // MomentsRealm Noti
    
    var diaryRealmArr: Results<DiaryModelRealm>?
    var diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()
    var arraySerction: [String] = []
    
    let onboardingDiarySet = BehaviorRelay<[Int: String]?>(value: nil)
    
    // filter 적용할 때, 원래 PageNum을 저장해놓고 필터가 끝났을때 다시 쓸 수 있도록
    var prevLastPageNum: Int = 0
    
    // Moments
    var momentsRealm: MomentsRealm?

    init(
        presenter: DiaryHomePresentable,
        dependency: DiaryHomeInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        self.filteredDiaryDic = dependency.diaryRepository.filteredDiaryDic
        super.init(presenter: presenter)
        presenter.listener = self
        self.presentationDelegateProxy.delegate = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
        bindMoments()
        bindFilter()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func bind() {
        print("DiaryHomeInteractor :: Bind!")
        // PushNotification을 누르고 UUID가 들어올 경우 Detail 페이지로 넘겨줌
        dependency.diaryUUIDRelay
            .filter ({ $0.count != 0 })
            .subscribe(onNext: { [weak self] uuid in
                guard let self = self else { return }
                
                print("DiaryHome :: uuid 받았어요! = \(uuid)")
                guard let realm = Realm.safeInit() else { return }
                guard let diaryModel = realm.objects(DiaryModelRealm.self).filter ({ $0.uuid == uuid }).first else { return }
                self.router?.attachDiaryDetail(model: diaryModel)
            })
            .disposed(by: disposebag)

        dependency.diaryRepository
            .filteredDiaryDic
            .subscribe(onNext: { [weak self] diarySectionModel in
                guard let self = self else { return }
                guard let diarySectionModel = diarySectionModel else { return }

                self.prevLastPageNum = self.lastPageNumRelay.value
                self.lastPageNumRelay.accept(diarySectionModel.allCount)
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
                    let filteredModel = model
                        .toArray(type: DiaryModelRealm.self)
                        .filter ({ $0.isDeleted == false })
                        .sorted(by: { $0.createdAt > $1.createdAt })

                    // 전체 PageNum 추려내기
                    let lastPageNum = filteredModel
                        .first?.pageNum ?? 0
                    print("DiaryHome :: lastPageNumRelay = \(self.lastPageNumRelay.value)")
                    self.lastPageNumRelay.accept(lastPageNum)

                    // 초기에는 필터 적용이 아니므로 false 전달
                    self.presenter.isFilteredRelay.accept(false)

                    // Set로 중복되지 않도록, Section Header Name 추가 (2022.12, 2022.11 등)
                    var section = Set<String>()
                    filteredModel.forEach { section.insert($0.createdAt.toStringWithYYYYMM()) }

                    // for문으로 체크하기 위해서 Array로 변경
                    self.arraySerction = Array(section)
                    self.arraySerction.sort { $0 > $1 }
                    self.arraySerction.enumerated().forEach { (index: Int, sectioName: String) in
                        self.diaryDictionary[sectioName] = DiaryHomeSectionModel(sectionName: sectioName, sectionIndex: index, diaries: [])
                    }
                    // let sortedModel: [DiaryModelRealm] = model.sorted(by: { $0.createdAt > $1.createdAt })
                    for diary in filteredModel {
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()
                        self.diaryDictionary[sectionName]?.diaries.append(diary)
                    }
                    print("DiaryHome :: diaryDictionary = \(self.diaryDictionary)")
                    print("DiaryHome :: sectionSet = \(section)")

                    self.setOnboardingDiaries()
                    self.presenter.reloadTableView()
                    
                case .update(let model, let deletions, let insertions, let modifications):
                    print("DiaryHome :: update! = \(model)")

                    // diaryModelRealm이 업데이트 될 때마다 온보딩 다이어리 업데이트가 필요하면 진행하도록
                    self.setOnboardingDiaries()

                    if insertions.count > 0 {
                        for insertionRow in insertions {
                            let diary: DiaryModelRealm = model[insertionRow]
                            let sectionName: String = diary.createdAt.toStringWithYYYYMM()

                            // 글이 하나도 없을 경우에는 sectionIndex 0에 작성될 수 있도록
                            let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex ?? 0
                            var needInsertSection: Bool = false
                            if self.diaryDictionary[sectionName] == nil {
                                for secName in self.arraySerction {
                                    self.diaryDictionary[secName]?.sectionIndex += 1
                                }
                                self.diaryDictionary[sectionName] = DiaryHomeSectionModel(sectionName: sectionName,
                                                                                          sectionIndex: 0,
                                                                                          diaries: []
                                )
                                needInsertSection = true
                            }

                            // 전체 pageNum 추려내기
                            let lastPageNum = model.filter { $0.isDeleted == false }
                                .sorted { $0.createdAt > $1.createdAt }
                                .first?.pageNum ?? 0
                            
                            self.lastPageNumRelay.accept(lastPageNum)
                            self.diaryDictionary[sectionName]?.diaries.insert(diary, at: 0)
                            self.presenter.insertTableViewRow(section: sectionIndex, row: 0)
                        }
                    }
                        
                    if modifications.count > 0 {
                        guard let modificationsRow: Int = modifications.first else { return }
                        print("DiaryHome :: realmObserve = modifications = \(modifications)")
                        let diary: DiaryModelRealm = model[modificationsRow]
                        let sectionName: String = diary.createdAt.toStringWithYYYYMM()

                        guard let diaries: [DiaryModelRealm] = self.diaryDictionary[sectionName]?.diaries,
                              let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex,
                              let row: Int = diaries.indices.filter ({ diaries[$0].uuid == diary.uuid }).first
                        else { return }
                        
                        // 삭제일때
                        if diary.isDeleted == true {
                            self.dependency.momentsRepository.deleteMoments(uuid: diary.uuid)
                            // 전체 PageNum 추려내기
                            let lastPageNum = model.filter { $0.isDeleted == false }
                                .sorted { $0.createdAt > $1.createdAt }
                                .first?.pageNum ?? 0

                            self.lastPageNumRelay.accept(lastPageNum)
                            self.diaryDictionary[sectionName]?.diaries.remove(at: row)
                            self.presenter.deleteTableViewRow(section: sectionIndex, row: row)
                            print("DiaryHome :: delete! = \(self.diaryDictionary)")
                            
                            if let diaryCount: Int = self.diaryDictionary[sectionName]?.diaries.count,
                               diaryCount == 0 {
                                print("DiaryHome :: 지워야할 것 같은걸")
                                let sectionIndex: Int = self.diaryDictionary[sectionName]?.sectionIndex ?? 0
                                print("DiaryHome :: sectionIndex = \(sectionIndex)")
                                self.diaryDictionary[sectionName] = nil
                                for secName in self.arraySerction {
                                    self.diaryDictionary[secName]?.sectionIndex -= 1
                                }
                                self.presenter.deleteTableViewSection(section: sectionIndex)
                            }
                        }
                        // 수정일때
                        else {
                            self.diaryDictionary[sectionName]?.diaries[row] = diary
                            self.presenter.reloadTableViewRow(section: sectionIndex, row: row)
                        }
                    }
                        
                    case .error(let error):
                        fatalError("\(error)")
                }
            }
    }
    
    func bindMoments() {
        guard let realm = Realm.safeInit() else { return }
        notificationTokenMoments = realm.objects(MomentsRealm.self)
            .observe({ [weak self] changes in
                guard let self = self else { return }
                switch changes {
                case .initial(let model):
                    print("DiaryHome :: Moments :: init! = \(model)")
                    self.momentsRealm = model.toArray(type: MomentsRealm.self).first
                    self.presenter.reloadCollectionView()
                    
                case .update(let model, let deletions, let insertions, let modifications):
                    print("DiaryHome :: Moments! update! = \(model)")
                    self.setOnboardingDiaries()
                    
                    if modifications.count > 0 {
                        print("DiaryHome :: Moments! modifications! -> 메뉴얼 불러오기 등..")
                        guard let momentsRealm = realm.objects(MomentsRealm.self).toArray(type: MomentsRealm.self).first
                        else { return }
                        self.momentsRealm = momentsRealm
                        self.presenter.reloadCollectionView()
                    }

                    if deletions.count > 0 {
                        print("DiaryHome :: Moments! delete!")
                        guard let momentsRealm = realm.objects(MomentsRealm.self).toArray(type: MomentsRealm.self).first
                        else { return }
                        self.momentsRealm = momentsRealm
                        self.presenter.reloadCollectionView()
                    }
                    break
                    
                    
                case .error(let error):
                    print("DiaryHome :: MomentsError! = \(error)")
                }
            })
    }
    
    func bindFilter() {
        filterResetBtnRelay
            .subscribe(onNext: { [weak self] isResetClicked in
                guard let self = self else { return }
                if isResetClicked == false { return }
                print("DiaryHomeIntreactor :: filterResetBtnRelay! = \(isResetClicked)")
                self.pressedFilterResetBtn()
        })
            .disposed(by: disposebag)
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
        router?.detachMyPage(isOnlyDetach: isOnlyDetach, isAnimated: true)
    }
    
    func restoreSuccess() {
        print("DiaryHomeInteractor :: restoreSuccess!")
        router?.detachMyPage(isOnlyDetach: false, isAnimated: false)
        presenter.showRestoreSuccessToast()
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
    func pressedMomentsCell(momentsItem: MomentsItemRealm) {
        guard let realm = Realm.safeInit() else { return }
        guard let diaryModel = realm.objects(DiaryModelRealm.self).filter ({ $0.uuid == momentsItem.diaryUUID }).first else { return }

        dependency.momentsRepository.visitMoments(momentsItem: momentsItem)
        
        // 방문 기록 +1
        realm.safeWrite {
            diaryModel.readCount += diaryModel.readCount + 1
        }
        router?.attachDiaryDetail(model: diaryModel)
    }
    
    // MARK: - Diary Writing 관련 함수
    func pressedWritingBtn() {
        print("DiaryHomeInteractor :: pressedWritingBtn!")
        router?.attachDiaryWriting(page: lastPageNumRelay.value + 1)
    }
    
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: ShowToastType) {
        if isNeedToast {
            presenter.isShowToastDiaryResultRelay.accept(mode)
        }

        router?.detachDiaryWriting(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - Diary detaill 관련 함수
    func pressedDiaryCell(diaryModel: DiaryModelRealm) {
        router?.attachDiaryDetail(model: diaryModel)
    }

    //ㅅㅏㄹㅏㅇㅎㅐ i luv u ㅅㅏㄹㅏㅇㅅㅏㄹㅏㅇㅎㅐ ㅅㅏㄹ6ㅎㅐ jjikkyu
    //22.12.12 월요일 진균이가 아직도 위에 사랑해 주석을 제거하지 않아서 기분이 좋은 수진이어따!
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryDetail(isOnlyDetach: isOnlyDetach)
    }
    
    func diaryDeleteNeedToast(isNeedToast: Bool) {
        print("DiaryHome :: diaryDeleteNeedToast = \(isNeedToast)")
        presenter.isShowToastDiaryResultRelay.accept(.delete)
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
        
        // double check
        if prevLastPageNum == 0 {
            guard let realm = Realm.safeInit() else { return }
            let pageNum = realm.objects(DiaryModelRealm.self)
                .toArray(type: DiaryModelRealm.self)
                .filter ({ $0.isDeleted == false })
                .sorted(by: { $0.createdAt > $1.createdAt })
                .first?.pageNum ?? 0

            self.lastPageNumRelay.accept(pageNum)
        } else {
            self.lastPageNumRelay.accept(prevLastPageNum)
        }

        self.presenter.reloadTableView()
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

// MARK: - OnBoarding
extension DiaryHomeInteractor {
    /// 온보딩이 필요한지 체크하고, 필요하다면 값을 넣어줄 수 있도록 하는 함수
    func setOnboardingDiaries() {
        print("DiaryHomeInteractor :: setOnboardingDiaries!")
        guard let realm = Realm.safeInit() else { return }
        guard let momentsRealm = realm.objects(MomentsRealm.self).first else { return }
        // onboarding이 보일 필요가 없으면 return
        if momentsRealm.onboardingIsClear == true {
            onboardingDiarySet.accept(nil)
            return
        }

        let diaries = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .filter ({ $0.isDeleted == false })

        var sortedModelArr: [String] = []
        let isDebugMode: Bool = UserDefaults.standard.bool(forKey: "debug")
        // 디버그 모드일 경우에는 다이어리 작성일자 카운트 하지 않고 나타날 수 있도록
        if isDebugMode {
            var diaryArr: [String] = []
            for diary in diaries {
                let date = diary.createdAt.toStringWithMMdd()
                diaryArr.append(date)
            }

            sortedModelArr = diaryArr
                .sorted(by: { $0 < $1 })
        } else {
            // 중복되지 않게 set에 날짜 insert
            var diarySet: Set<String> = []
            for diary in diaries {
                let date = diary.createdAt.toStringWithMMdd()
                diarySet.insert(date)
            }

            // 정렬
            sortedModelArr = Array(diarySet)
                .sorted(by: { $0 < $1 })
        }
        
        // onboarding UI가 보일 수 있도록 형변환
        var writingDiarySet: [Int: String] = [:]
        for (index, date) in sortedModelArr.enumerated() {
            writingDiarySet[index + 1] = date
        }

        // 14개 이상 작성이 완료되었을 경우 다음날 부터 모먼츠 제공될 수 있도록 체크
        if writingDiarySet.count >= 14 {
            dependency.momentsRepository
                .clearOnboarding()
        }
        
        onboardingDiarySet.accept(writingDiarySet)
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
