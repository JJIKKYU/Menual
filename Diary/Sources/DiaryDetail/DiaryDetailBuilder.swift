//
//  DiaryDetailBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxRelay
import MenualEntity
import MenualRepository
import DiaryBottomSheet
import DiaryWriting
import DiaryDetailImage

public protocol DiaryDetailDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

public final class DiaryDetailComponent: Component<DiaryDetailDependency>, DiaryDetailInteractorDependency, DiaryBottomSheetDependency, DiaryWritingDependency, DiaryDetailImageDependency {
    
    public var filterResetBtnRelay: RxRelay.BehaviorRelay<Bool>?
    public var isEnabledReminderRelay: BehaviorRelay<Bool?>?
    public var isHideMenualRelay: BehaviorRelay<Bool>?
    public var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    public var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    public var filteredDiaryCountRelay: BehaviorRelay<Int>?
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>?

}

// MARK: - Builder

public protocol DiaryDetailBuildable: Buildable {
    func build(
        withListener listener: DiaryDetailListener,
        diaryModel: DiaryModelRealm
    ) -> DiaryDetailRouting
}

public final class DiaryDetailBuilder: Builder<DiaryDetailDependency>, DiaryDetailBuildable {

    public override init(dependency: DiaryDetailDependency) {
        super.init(dependency: dependency)
    }
    
    public func build(withListener listener: DiaryDetailListener, diaryModel: DiaryModelRealm) -> DiaryDetailRouting {
        let component = DiaryDetailComponent(
            dependency: dependency
        )
        
        let diaryBottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        let diaryDetailImageBuildable = DiaryDetailImageBuilder(dependency: component)

        let viewController = DiaryDetailViewController()
        viewController.screenName = "detail"
        let interactor = DiaryDetailInteractor(
            presenter: viewController,
            diaryModel: diaryModel,
            dependency: component
        )
        
        interactor.listener = listener
        component.reminderRequestDateRelay = interactor.reminderRequestDateRelay
        component.isHideMenualRelay = interactor.isHideMenualRelay
        component.isEnabledReminderRelay = interactor.isEnabledReminderRelay
        
        return DiaryDetailRouter(
            interactor: interactor,
            viewController: viewController,
            diarybottomSheetBuildable: diaryBottomSheetBuildable,
            diaryWritingBuildable: diaryWritingBuildable,
            diaryDetailImageBuildable: diaryDetailImageBuildable
        )
    }
}
