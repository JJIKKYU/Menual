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
            })
            .disposed(by: disposeBag)
        
        dependency.isHideMenualRelay?
            .subscribe(onNext: { [weak self] isHide in
                guard let self = self else { return }
                print("DiaryBottomSheet :: isHide = \(isHide)")
                self.presenter.setHideBtnTitle(isHide: isHide)
            })
            .disposed(by: disposeBag)
        
        /*
        dependency.diaryRepository
            .diaryMonthDic
            .subscribe(onNext: { [weak self] diaryMonthDic in
                guard let self = self else { return }
                
                print("DiaryBottomSheet :: DiaryMonthDic! - 1 = \(diaryMonthDic)")
                
                var dateFilterModelArr: [DateFilterModel] = []
                diaryMonthDic.forEach {
                    let year = $0.year
                    let months: [DateFilterMonthsModel] = $0.months?.getIsValidDiary() ?? []

                    dateFilterModelArr.append(DateFilterModel(year: year, months: months))
                }
                
                print("DiaryBottomSheet :: DiaryMonthDic! - 2 = \(dateFilterModelArr)")
                
                self.dateFilterModelRelay?.accept(dateFilterModelArr.sorted { $0.year < $1.year })
//                let year = diaryMonthDic.forEach { diaryYearModel in
//                    diaryYearModel.year
//                }
            })
            .disposed(by: disposeBag)
        */
        dependency.diaryRepository
            .diaryString
            .subscribe(onNext: { [weak self] diaryArr in
                guard let self = self else { return }
                
                // 월을 세팅해보자
                var monthSet = [Int: [Int: Int]]()
                var test = [Int: [DateFilterMonthsModel]]()
                diaryArr
                    .forEach { diary in
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
                    if test[year] == nil {
                        test[year] = []
                    }
                    for value in monthDic {
                        let month = value.key
                        let monthCount = value.value
                        test[year]?.append(DateFilterMonthsModel(month: month, diaryCount: monthCount))
                    }
                }
                
                print("DiaryBottomSheet :: monthSet = \(monthSet), test = \(test)")
                
                /*
                var yearMonthSet = [Int: [Set<Int>: Int]]()
                diaryArr
                    .forEach { diary in
                        let yearString: Int = Int(diary.createdAt.toStringWithYYYY()) ?? 0
                        let monthString: Int = Int(diary.createdAt.toStringWithMM()) ?? 0

                        if yearMonthSet[yearString] == nil {
                            yearMonthSet[yearString] = [:]
                        }
                        let a = yearMonthSet[yearString]?[monthString]?
                        print("DiaryBottomSheet :: yearString = \(yearString), \(monthString)")
                    }
                */
                
//                var dateFilterMonthModelArr: [DateFilterMonthsModel] = []
//                yearMonthSet.forEach { (key: Int, value: Set<Int>) in
//
//                }

                /*
                var diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()
                
                var yearMonthSet = Set<String>()
                diaryArr.forEach { yearMonthSet.insert($0.createdAt.toStringWithYYYYMM()) }

                // for문으로 체크하기 위해서 Array로 변경
                var arrayYear = Array(yearMonthSet)
                arrayYear.forEach { (yearMonthString: String) in
                    diaryDictionary[yearMonthString] = DiaryHomeSectionModel(sectionName: yearMonthString,
                                                                             sectionIndex: 0,
                                                                             diaries: []
                    )
                }
                for diary in diaryArr {
                    let sectionName: String = diary.createdAt.toStringWithYYYYMM()
                    diaryDictionary[sectionName]?.diaries.append(diary)
                }
                
                diaryDictionary.forEach { (yearMonthString: String, value: DiaryHomeSectionModel) in
                    let dateFilterMonthModel = DateFilterMonthsModel(month: yearMonthString,
                                                                     diaryCount: value.diaries.count
                    )
                }
                
                print("DiaryBottomSheet :: DiaryString! = \(yearMonthSet)")
                let dateFilterModel: [DateFilterModel] = []

                // self.dateFilterModelRelay?.accept(<#T##event: [DateFilterModel]?##[DateFilterModel]?#>)
                self.dateFilterModelRelay?.accept(<#T##event: [DateFilterModel]?##[DateFilterModel]?#>)
                 */
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
    func filterDatePressedFilterBtn(yearDateFormatString: String) {
        listener?.filterDatePressedFilterBtn(yearDateFormatString: yearDateFormatString)
    }
}

// MARK: - 미사용
extension DiaryBottomSheetInteractor {
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType) {
        
    }
}
