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
import DiaryWriting

// 사용하려고 하는 곳에만 Dependency 설정
public extension DiaryBottomSheetDependency {
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { nil }
    var isHideMenualRelay: BehaviorRelay<Bool>? { nil }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { nil }
}

public protocol DiaryBottomSheetDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
    var filteredDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var filterResetBtnRelay: BehaviorRelay<Bool>? { get }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
}

public final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency>, DiaryWritingDependency, DiaryBottomSheetInteractorDependency {
    
    public var filterResetBtnRelay: BehaviorRelay<Bool>? { dependency.filterResetBtnRelay }
    public var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { dependency.reminderRequestDateRelay }
    public var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { dependency.filteredWeatherArrRelay }
    public var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { dependency.filteredPlaceArrRelay }
    public var filteredDiaryCountRelay: BehaviorRelay<Int>? { dependency.filteredDiaryCountRelay }
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var isHideMenualRelay: BehaviorRelay<Bool>? { dependency.isHideMenualRelay }
    public var isEnabledReminderRelay: BehaviorRelay<Bool?>? { dependency.isEnabledReminderRelay }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    public override init(
        dependency: DiaryBottomSheetDependency
    ) {
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol DiaryBottomSheetBuildable: Buildable {
    func build(
        withListener listener: DiaryBottomSheetListener,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) -> DiaryBottomSheetRouting
}

public final class DiaryBottomSheetBuilder: Builder<DiaryBottomSheetDependency>, DiaryBottomSheetBuildable {

    public override init(dependency: DiaryBottomSheetDependency) {
        super.init(dependency: dependency)
    }

    public func build(
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
