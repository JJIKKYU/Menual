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
    var isShowToastDiaryResultRelay: BehaviorRelay<DiaryWritingInteractor.DiaryWritingMode?> { get }
    
    func reloadTableView()
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
    var diaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]>
    var filteredDiaryMonthSetRelay: BehaviorRelay<[DiaryYearModel]>
    let filteredDiaryCountRelay = BehaviorRelay<Int>(value: -1)
    
    let filteredWeatherArrRelay = BehaviorRelay<[Weather]>(value: [])
    let filteredPlaceArrRelay = BehaviorRelay<[Place]>(value: [])
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
        self.diaryMonthSetRelay = dependency.diaryRepository.diaryMonthDic
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
            .diaryString
            .subscribe(onNext: { [weak self] diaryArr in
                guard let self = self else { return }
                print("diaryString 구독 중!, diary = \(diaryArr)")
                print("<- reloadTableView")
                
                // 전체 PageNum 추려내기
                let lastPageNum = diaryArr.sorted { $0.createdAt > $1.createdAt }.first?.pageNum ?? 0
                self.lastPageNumRelay.accept(lastPageNum)
                
                self.presenter.isFilteredRelay.accept(false)
                self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)
        
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
        
        dependency.diaryRepository
            .diaryMonthDic
            .subscribe(onNext: { [weak self] monthSet in
                guard let self = self else { return }
                print("monthSet 구독중! \(monthSet)")
                
                self.presenter.isFilteredRelay.accept(false)
                self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)

        /*
        dependency.diaryRepository
            .realmDiaryOb
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                print("아이클라우드에서 받아온 정보 : \(data)")
                // self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)
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
    
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryWritingInteractor.DiaryWritingMode) {
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
        dependency.diaryRepository
            .fetch()
    }
}
