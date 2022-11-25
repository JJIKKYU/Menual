//
//  DiaryDetailBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxRelay

protocol DiaryDetailDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class DiaryDetailComponent: Component<DiaryDetailDependency>, DiaryDetailInteractorDependency, DiaryBottomSheetDependency, DiaryWritingDependency, DiaryDetailImageDependency {

    var isHideMenualRelay: BehaviorRelay<Bool>?
    var filteredDateDiaryCountRelay: RxRelay.BehaviorRelay<Int>?
    var filteredDateRelay: BehaviorRelay<Date?>?
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>?

}

// MARK: - Builder

protocol DiaryDetailBuildable: Buildable {
    func build(
        withListener listener: DiaryDetailListener,
        diaryModel: DiaryModel
    ) -> DiaryDetailRouting
}

final class DiaryDetailBuilder: Builder<DiaryDetailDependency>, DiaryDetailBuildable {

    override init(dependency: DiaryDetailDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: DiaryDetailListener, diaryModel: DiaryModel) -> DiaryDetailRouting {
        let component = DiaryDetailComponent(
            dependency: dependency
        )
        
        let diaryBottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        let diaryDetailImageBuildable = DiaryDetailImageBuilder(dependency: component)

        let viewController = DiaryDetailViewController()
        let interactor = DiaryDetailInteractor(
            presenter: viewController,
            diaryModel: diaryModel,
            dependency: component
        )
        
        interactor.listener = listener
        component.reminderRequestDateRelay = interactor.reminderRequestDateRelay
        component.isHideMenualRelay = interactor.isHideMenualRelay
        
        return DiaryDetailRouter(
            interactor: interactor,
            viewController: viewController,
            diarybottomSheetBuildable: diaryBottomSheetBuildable,
            diaryWritingBuildable: diaryWritingBuildable,
            diaryDetailImageBuildable: diaryDetailImageBuildable
        )
    }
}
