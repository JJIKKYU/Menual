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

protocol DiaryDetailDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class DiaryDetailComponent: Component<DiaryDetailDependency>, DiaryDetailInteractorDependency, DiaryBottomSheetDependency, DiaryWritingDependency, DiaryDetailImageDependency {
    
    var isEnabledReminderRelay: BehaviorRelay<Bool?>?
    var isHideMenualRelay: BehaviorRelay<Bool>?
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>?

}

// MARK: - Builder

protocol DiaryDetailBuildable: Buildable {
    func build(
        withListener listener: DiaryDetailListener,
        diaryModel: DiaryModelRealm
    ) -> DiaryDetailRouting
}

final class DiaryDetailBuilder: Builder<DiaryDetailDependency>, DiaryDetailBuildable {

    override init(dependency: DiaryDetailDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: DiaryDetailListener, diaryModel: DiaryModelRealm) -> DiaryDetailRouting {
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
