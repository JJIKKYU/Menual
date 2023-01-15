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
import Foundation

protocol DiaryBottomSheetRouting: ViewableRouting {
    
}

protocol DiaryBottomSheetPresentable: Presentable {
    var listener: DiaryBottomSheetPresentableListener? { get set }

    func setFilterBtnCount(count: Int)
    func setViews(type: MenualBottomSheetType)
    func setCurrentFilteredBtn(weatherArr: [Weather], placeArr: [Place])
    func setCurrentReminderData(isEnabled: Bool, dateComponets: DateComponents?)
    func setHideBtnTitle(isHide: Bool)
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place])
    func filterWithWeatherPlacePressedFilterBtn()
    func reminderCompViewshowToast(isEding: Bool)
    func filterDatePressedFilterBtn(yearDateFormatString: String)
}

protocol DiaryBottomSheetInteractorDependency {
    var diaryRepository: DiaryRepository { get }
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
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDiaryCountRelay }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { dependency.filteredWeatherArrRelay }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { dependency.filteredPlaceArrRelay }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { dependency.reminderRequestDateRelay }
    var isHideMenualRelay: BehaviorRelay<Bool>? { dependency.isHideMenualRelay }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { dependency.isEnabledReminderRelay }
    var dateFilterModelRelay: RxRelay.BehaviorRelay<[DateFilterModel]?>? = BehaviorRelay<[DateFilterModel]?>(value: nil)

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
        self.setDateFilter()
        presenter.listener = self
        presenter.setViews(type: bottomSheetType)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
        setDateFilter()
    }

    override func willResignActive() {
        super.willResignActive()
    }

    // DateFilter일 경우 메뉴얼 갯수 세팅 필요
    func setDateFilter() {
        if bottomSheetType != .dateFilter { return }
        guard let realm = Realm.safeInit() else { return }
        let diaryArr = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .sorted(by: ({ $0.createdAt < $1.createdAt }))
        
        
        // 월을 세팅해보자
        var monthSet: [Int: [Int: Int]] = [:]
        var yearDateFilterMonthsModel = [Int: [DateFilterMonthsModel]]()
        diaryArr
            .forEach { diary in
                print("diary :: diary! = \(diary)")
                let year: Int = Int(diary.createdAt.toStringWithYYYY()) ?? 0
                let month: Int = Int(diary.createdAt.toStringWithMM()) ?? 0
                if monthSet[year] == nil {
                    monthSet[year] = [:]
                }
                if monthSet[year]![month] == nil {
                    monthSet[year]![month] = 0
                }

                monthSet[year]![month]! += 1
            }
        
        for data in monthSet {
            let year = data.key
            let monthDic = data.value
            if yearDateFilterMonthsModel[year] == nil {
                yearDateFilterMonthsModel[year] = []
            }

            var dateFilterMonthsModelArr: [DateFilterMonthsModel] = []
            for value in monthDic {
                let month = value.key
                let monthCount = value.value
                dateFilterMonthsModelArr.append(DateFilterMonthsModel(month: month, diaryCount: monthCount))
                // yearDateFilterMonthsModel[year]?.append(DateFilterMonthsModel(month: month, diaryCount: monthCount))
            }
            
            let result = dateFilterMonthsModelArr.sorted(by: ({ $0.month < $1.month }))
            yearDateFilterMonthsModel[year] = result
        }
        var dateFilterModelArr = [DateFilterModel]()
        print("DiaryBottomSheet :: yearDateFilterMonthsModel \(yearDateFilterMonthsModel)")
        
        // 2023년, 2022년.. 순서대로 들어갈 수 있도록 소팅
        let sortedYearDateFilterMonthsModel = Array(yearDateFilterMonthsModel).sorted(by: { $0.key > $1.key })
        for value in sortedYearDateFilterMonthsModel {
            dateFilterModelArr.insert(DateFilterModel(year: value.key, months: value.value), at: 0)
        }
        print("DiaryBottomSheet :: dateFilterModelArr = \(dateFilterModelArr)")
        self.dateFilterModelRelay?.accept(dateFilterModelArr)
    }
    
    func bind() {
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
                self.presenter.setCurrentFilteredBtn(weatherArr: weatherArr, placeArr: placeArr)
            })
            .disposed(by: disposeBag)
        }
        
        dependency.reminderRequestDateRelay?
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                print("DiaryBottomSheet :: 나중에 수정 만들때 하면 될듯")
                
                let isEnabled: Bool = model == nil ? false : true
                self.presenter.setCurrentReminderData(isEnabled: isEnabled, dateComponets: model?.requestDateComponents)
            })
            .disposed(by: disposeBag)
        
        dependency.isHideMenualRelay?
            .subscribe(onNext: { [weak self] isHide in
                guard let self = self else { return }
                print("DiaryBottomSheet :: isHide = \(isHide)")
                self.presenter.setHideBtnTitle(isHide: isHide)
            })
            .disposed(by: disposeBag)
    }
    
    func pressedCloseBtn() {
        print("pressedCloseBtn")
        listener?.diaryBottomSheetPressedCloseBtn()
        // filteredPlaceArrRelay?.accept([])
        // filteredWeatherArrRelay?.accept([])
        isEnabledReminderRelay?.accept(nil)
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
    func filterDatePressedFilterBtn(yearDateFormatString: String) {
        listener?.filterDatePressedFilterBtn(yearDateFormatString: yearDateFormatString)
    }
}

// MARK: - 미사용
extension DiaryBottomSheetInteractor {
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType) {
    }
}
