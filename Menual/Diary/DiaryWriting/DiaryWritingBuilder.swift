//
//  DiaryWritingBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxRelay

protocol DiaryWritingDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingComponent: Component<DiaryWritingDependency>, DiaryWritingInteractorDependency, DiaryBottomSheetDependency, DiaryTempSaveDependency {
    
    var filteredDateRelay: BehaviorRelay<Date>?
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? // 미사용

}

// MARK: - Builder

protocol DiaryWritingBuildable: Buildable {
    func build(
        withListener listener: DiaryWritingListener,
        diaryModel: DiaryModel?,
        page: Int
    ) -> DiaryWritingRouting
}

final class DiaryWritingBuilder: Builder<DiaryWritingDependency>, DiaryWritingBuildable {

    override init(dependency: DiaryWritingDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryWritingListener,
        diaryModel: DiaryModel?,
        page: Int
    ) -> DiaryWritingRouting {
        let component = DiaryWritingComponent(dependency: dependency)
        
        let diaryBottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        
        let diaryTempSaveBuildable = DiaryTempSaveBuilder(dependency: component)
        
        let viewController = DiaryWritingViewController()
        let interactor = DiaryWritingInteractor(
            presenter: viewController,
            dependency: component,
            diaryModel: diaryModel,
            page: page
        )
        interactor.listener = listener
        return DiaryWritingRouter(
            interactor: interactor,
            viewController: viewController,
            diaryBottomSheetBuildable: diaryBottomSheetBuildable,
            diaryTempSaveBuildable: diaryTempSaveBuildable
        )
    }
}
