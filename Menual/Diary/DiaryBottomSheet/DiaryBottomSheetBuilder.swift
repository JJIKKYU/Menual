//
//  DiaryBottomSheetBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryBottomSheetDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredDateRelay: BehaviorRelay<Date?>? { get }
    var filteredDateDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
}

final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency>, DiaryWritingDependency, DiaryBottomSheetInteractorDependency {

    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? { dependency.reminderRequestDateRelay }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { dependency.filteredWeatherArrRelay }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { dependency.filteredPlaceArrRelay }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDiaryCountRelay }
    var filteredDateDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDateDiaryCountRelay }
    var filteredDateRelay: BehaviorRelay<Date?>? { dependency.filteredDateRelay }
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var isHideMenualRelay: BehaviorRelay<Bool>? { dependency.isHideMenualRelay }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    override init(
        dependency: DiaryBottomSheetDependency
    ) {
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol DiaryBottomSheetBuildable: Buildable {
    func build(
        withListener listener: DiaryBottomSheetListener,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) -> DiaryBottomSheetRouting
}

final class DiaryBottomSheetBuilder: Builder<DiaryBottomSheetDependency>, DiaryBottomSheetBuildable {

    override init(dependency: DiaryBottomSheetDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryBottomSheetListener,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) -> DiaryBottomSheetRouting {
        let component = DiaryBottomSheetComponent(dependency: dependency)
        print("ddddd!! =\(dependency.filteredDiaryCountRelay?.value)")
        
        let viewController = DiaryBottomSheetViewController()
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        
        let interactor = DiaryBottomSheetInteractor(
            presenter: viewController,
            dependency: component,
            bottomSheetType: bottomSheetType,
            menuComponentRelay: menuComponentRelay
        )
        print("ddddd!! = \(dependency.filteredDiaryCountRelay)")

        // filter
        // interactor.setFilteredDiaryCountRelay(relay: dependency.filteredDiaryCountRelay)
        // interactor.setFilteredWeatherPlaceArrRelay(weatherArrRelay: dependency.filteredWeatherArrRelay, placeArrRelay: dependency.filteredPlaceArrRelay)
        
        // date filter
//        interactor.setFilteredDateRelay(relay: dependency.filteredDateRelay, countRelay: dependency.filteredDateDiaryCountRelay)
        
        // reminder
        // interactor.setReminderRequestDate(relay: dependency.reminderRequestDateRelay)

        interactor.listener = listener

        return DiaryBottomSheetRouter(
            interactor: interactor,
            viewController: viewController,
            diaryWritingBuildable: diaryWritingBuildable
        )
    }
}
