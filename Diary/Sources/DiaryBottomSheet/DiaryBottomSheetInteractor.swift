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
import MenualUtil
import MenualEntity
import DesignSystem
import MenualRepository

// MARK: - DiaryBottomSheetRouting

public protocol DiaryBottomSheetRouting: ViewableRouting {
    
}

// MARK: - DiaryBottomSheetPresentable

public protocol DiaryBottomSheetPresentable: Presentable {
    var listener: DiaryBottomSheetPresentableListener? { get set }

    func setFilterBtnCount(count: Int)
    func setViews(type: MenualBottomSheetType) async
    func setCurrentReminderData(isEnabled: Bool, dateComponets: DateComponents?)
    func setHideBtnTitle(isHide: Bool)
    func goReviewPage()
}

// MARK: - DiaryBottomSheetListener

public protocol DiaryBottomSheetListener: AnyObject {
    func diaryBottomSheetPressedCloseBtn()
    
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place])
    func filterWithWeatherPlacePressedFilterBtn()
    func reminderCompViewshowToast(type: ReminderToastType)
    // 개발자에게 문의하기
    func reviewCompoentViewPresentQA()
    
    // 알람
    func setAlarm(date: Date, days: [Weekday]) async
}

// MARK: - DiaryBottomSheetInteractorDependency

public protocol DiaryBottomSheetInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
    var notificationRepository: NotificationRepository? { get }
}

// MARK: - DiaryBottomSheetInteractor

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

    private let dependency: DiaryBottomSheetInteractorDependency

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
        Task {
            await presenter.setViews(type: bottomSheetType)
        }
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
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
    
    func reminderCompViewshowToast(type: ReminderToastType) {
        listener?.reminderCompViewshowToast(type: type)
    }

    func reminderCompViewSetReminder(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date) {
        // self.reminderRequestDateRelay?.accept(requestDateComponents)
    }
    
    // MARK: - ReviewComponenet
    
    func pressedReviewBtn() {
        presenter.goReviewPage()
        dependency.appstoreReviewRepository
            .approveReview()
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    func pressedInquiryBtn() {
        dependency.appstoreReviewRepository
            .rejectReview()
        listener?.diaryBottomSheetPressedCloseBtn()
        listener?.reviewCompoentViewPresentQA()
    }
    
    // MARK: - AlarmComponent
    
    func pressedAlarmConfirmBtn(date: Date, days: [Weekday]) {
        Task {
            await listener?.setAlarm(date: date, days: days)
            listener?.diaryBottomSheetPressedCloseBtn()
        }
    }
    
    func getCurrentNotifications() async -> [Weekday] {
        guard let weekdays = await dependency.notificationRepository?
            .getCurrentWeekdays() else { return [] }
        return weekdays
    }

    func getCurrentNotificationTime() async -> Date? {
        guard let time = await dependency.notificationRepository?
            .getCurrentNotificationTime() else { return nil }
        return time
    }
}

// MARK: - 미사용

extension DiaryBottomSheetInteractor {
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: ShowToastType) {
    }
}
