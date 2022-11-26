//
//  DiaryBottomSheetInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift

protocol DiaryBottomSheetRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryBottomSheetPresentable: Presentable {
    var listener: DiaryBottomSheetPresentableListener? { get set }

    func setFilterBtnCount(count: Int)
    func setViews(type: MenualBottomSheetType)
    func setCurrentFilteredBtn(weatherArr: [Weather], placeArr: [Place])
    func setCurrentReminderData(isEnabled: Bool, dateComponets: DateComponents?)
    func setDateFilteredRelay()
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place])
    func filterWithWeatherPlacePressedFilterBtn()
    func reminderCompViewshowToast(isEding: Bool)
    func filterDatePressedFilterBtn()
    func setHideBtnTitle(isHide: Bool)
}

protocol DiaryBottomSheetInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var filteredDateRelay: BehaviorRelay<Date?>? { get }
    var filteredDateDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {
    
    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    var disposeBag = DisposeBag()
    var bottomSheetType: MenualBottomSheetType = .menu

    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    var filteredDateDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDateDiaryCountRelay }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDiaryCountRelay }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { dependency.filteredWeatherArrRelay }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { dependency.filteredPlaceArrRelay }
    var filteredDateRelay: BehaviorRelay<Date?>? { dependency.filteredDateRelay }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { dependency.reminderRequestDateRelay }
    var isHideMenualRelay: BehaviorRelay<Bool>? { dependency.isHideMenualRelay }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { dependency.isEnabledReminderRelay }

    private let dependency: DiaryBottomSheetInteractorDependency

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryBottomSheetPresentable,
        dependency: DiaryBottomSheetInteractorDependency,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) {
        self.bottomSheetType = bottomSheetType
        self.dependency = dependency
        if let menuComponentRelay = menuComponentRelay {
            self.menuComponentRelay = menuComponentRelay
        }

        print("menualBottomSheetType = \(bottomSheetType)")
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.setViews(type: bottomSheetType)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        dependency.filteredDateRelay?
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                print("DiaryBottomSheet :: filteredDateRelayt! = \(date)")
                self.presenter.setDateFilteredRelay()
            })
            .disposed(by: disposeBag)
        
        dependency.filteredDateDiaryCountRelay?
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                print("DiaryBottomSheet :: count! = \(count)")
            })
            .disposed(by: disposeBag)
        
        dependency.filteredDiaryCountRelay?
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                print("DiaryBottomSheet = setFilterCount! count = \(count)")
                self.presenter.setFilterBtnCount(count: count)
            })
            .disposed(by: disposeBag)
        
        if let filteredWeatherArrRelay = dependency.filteredWeatherArrRelay,
           let filteredPlaceArrRelay = dependency.filteredPlaceArrRelay {
            Observable.combineLatest(
                filteredWeatherArrRelay,
                filteredPlaceArrRelay
            )
            .subscribe(onNext: { [weak self] weatherArr, placeArr in
                guard let self = self else { return }
                
                print("DiaryBottomSheet :: !!! \(weatherArr), \(placeArr)")
                self.listener?.filterWithWeatherPlace(weatherArr: weatherArr, placeArr: placeArr)
            })
            .disposed(by: disposeBag)
        }
        
        dependency.reminderRequestDateRelay?
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                print("DiaryBottomSheet :: 나중에 수정 만들때 하면 될듯")
                
                let isEnabled: Bool = model == nil ? false : true
                self.presenter.setCurrentReminderData(isEnabled: isEnabled, dateComponets: model?.requestDateComponents)
                
                /*
                let isEnabled: Bool = date == nil ? false : true
                self.presenter.setCurrentReminderData(isEnabled: isEnabled, dateComponets: date)
                 */
            })
            .disposed(by: disposeBag)
        
        dependency.isHideMenualRelay?
            .subscribe(onNext: { [weak self] isHide in
                guard let self = self else { return }
                print("DiaryBottomSheet :: isHide = \(isHide)")
            })
            .disposed(by: disposeBag)
        
        dependency.diaryRepository
            .diaryMonthDic
            .subscribe(onNext: { [weak self] diaryMonthDic in
                guard let self = self else { return }
                
                print("DiaryBottomSheet :: DiaryMonthDic! - 1 = \(diaryMonthDic)")
                
                var dateFilterModelArr: [DateFilterModel] = []
                diaryMonthDic.forEach {
                    let year = $0.year
                    var months: [Int] = $0.months?.getIsValidDiary() ?? []
                    dateFilterModelArr.append(DateFilterModel(year: year, months: months))
                }
                
                print("DiaryBottomSheet :: DiaryMonthDic! - 2 = \(dateFilterModelArr)")
                
//                let year = diaryMonthDic.forEach { diaryYearModel in
//                    diaryYearModel.year
//                }
            })
            .disposed(by: disposeBag)
    }
    
    func pressedCloseBtn() {
        print("pressedCloseBtn")
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    func pressedWriteBtn() {
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    // MARK: - Place/Weahter Filter
    func filterWithWeatherPlacePressedFilterBtn() {
        listener?.filterWithWeatherPlacePressedFilterBtn()
    }
    
    // MARK: - DiaryWritingVC
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool) {
        print("diaryWritingPressedBackBtn!")
    }
    
    // MARK: - ReminderComponentView
    func reminderCompViewshowToast(isEding: Bool) {
        listener?.reminderCompViewshowToast(isEding: isEding)
    }

    func reminderCompViewSetReminder(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date) {
        // self.reminderRequestDateRelay?.accept(requestDateComponents)
    }
    
    
    // MARK: - DateFilater
    func filterDatePressedFilterBtn() {
        listener?.filterDatePressedFilterBtn()
    }
}

// MARK: - 미사용
extension DiaryBottomSheetInteractor {
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType) {
        
    }
}
