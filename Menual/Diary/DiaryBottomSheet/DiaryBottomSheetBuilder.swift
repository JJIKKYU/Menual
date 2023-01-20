//
//  DiaryBottomSheetBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay
import DesignSystem
import MenualEntity
import MenualRepository

// 사용하려고 하는 곳에만 Dependency 설정
extension DiaryBottomSheetDependency {
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { nil }
    var isHideMenualRelay: BehaviorRelay<Bool>? { nil }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { nil }
}

protocol DiaryBottomSheetDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
}

final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency>, DiaryWritingDependency, DiaryBottomSheetInteractorDependency {

    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { dependency.reminderRequestDateRelay }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { dependency.filteredWeatherArrRelay }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { dependency.filteredPlaceArrRelay }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDiaryCountRelay }
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var isHideMenualRelay: BehaviorRelay<Bool>? { dependency.isHideMenualRelay }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { dependency.isEnabledReminderRelay }

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
        viewController.screenName = "bottomSheet"
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        
        let interactor = DiaryBottomSheetInteractor(
            presenter: viewController,
            dependency: component,
            bottomSheetType: bottomSheetType,
            menuComponentRelay: menuComponentRelay
        )


        interactor.listener = listener

        return DiaryBottomSheetRouter(
            interactor: interactor,
            viewController: viewController,
            diaryWritingBuildable: diaryWritingBuildable
        )
    }
}
