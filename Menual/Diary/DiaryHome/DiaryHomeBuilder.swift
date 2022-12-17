//
//  DiaryHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxRelay

protocol DiaryHomeDependency: Dependency {
    // AppRootComponent에서 생성해서, 부모(AppRoot RIBs)로부터 받아옴
    var diaryRepository: DiaryRepository { get }
    var momentsRepository: MomentsRepository { get }
    var diaryUUIDRelay: BehaviorRelay<String> { get }
}

final class DiaryHomeComponent: Component<DiaryHomeDependency>, ProfileHomeDependency, DiarySearchDependency, DiaryMomentsDependency, DiaryWritingDependency, DiaryHomeInteractorDependency, DiaryDetailDependency, DesignSystemDependency, DiaryBottomSheetDependency {
    
    var diaryUUIDRelay: BehaviorRelay<String> { dependency.diaryUUIDRelay }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.

    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    var momentsRepository: MomentsRepository { dependency.momentsRepository }
    
    override init(
        dependency: DiaryHomeDependency
    ) {
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol DiaryHomeBuildable: Buildable {
    func build(
        withListener listener: DiaryHomeListener,
        diaryUUIDRelay: BehaviorRelay<String>?
    ) -> DiaryHomeRouting
}

final class DiaryHomeBuilder: Builder<DiaryHomeDependency>, DiaryHomeBuildable {

    override init(dependency: DiaryHomeDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryHomeListener,
        diaryUUIDRelay: BehaviorRelay<String>?
    ) -> DiaryHomeRouting {
        let component = DiaryHomeComponent(dependency: dependency)
        
        let profileHomeBuildable = ProfileHomeBuilder(dependency: component)
        let diarySearchBuildable = DiarySearchBuilder(dependency: component)
        let diaryMomentsBuildable = DiaryMomentsBuilder(dependency: component)
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        let diaryDetailBuildable = DiaryDetailBuilder(dependency: component)
        let designSystemBuildable = DesignSystemBuilder(dependency: component)
        let diaryBottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        
        let viewController = DiaryHomeViewController()
        let interactor = DiaryHomeInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        component.filteredDiaryCountRelay = interactor.filteredDiaryCountRelay
        component.filteredPlaceArrRelay = interactor.filteredPlaceArrRelay
        component.filteredWeatherArrRelay = interactor.filteredWeatherArrRelay
        
        return DiaryHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profileHomeBuildable: profileHomeBuildable,
            diarySearchBuildable: diarySearchBuildable,
            diaryMomentsBuildable: diaryMomentsBuildable,
            diaryWritingBuildable: diaryWritingBuildable,
            diaryDetailBuildable: diaryDetailBuildable,
            designSystemBuildable: designSystemBuildable,
            diarybottomSheetBuildable: diaryBottomSheetBuildable
        )
    }
}
