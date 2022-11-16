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
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? { get }
}

final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency>, DiaryWritingDependency {
    var diaryRepository: DiaryRepository { dependency.diaryRepository }

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
            bottomSheetType: bottomSheetType,
            menuComponentRelay: menuComponentRelay
        )
        print("ddddd!! = \(dependency.filteredDiaryCountRelay)")

        interactor.setFilteredDiaryCountRelay(relay: dependency.filteredDiaryCountRelay)
        interactor.setFilteredWeatherPlaceArrRelay(weatherArrRelay: dependency.filteredWeatherArrRelay, placeArrRelay: dependency.filteredPlaceArrRelay)
        interactor.setReminderRequestDate(relay: dependency.reminderRequestDateRelay)

        interactor.listener = listener

        return DiaryBottomSheetRouter(
            interactor: interactor,
            viewController: viewController,
            diaryWritingBuildable: diaryWritingBuildable
        )
    }
}
