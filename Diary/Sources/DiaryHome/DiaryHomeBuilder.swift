//
//  DiaryHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxRelay
import MenualEntity
import MenualRepository

import ZipArchive
import ProfileDesignSystem
import DiarySearch
import DiaryWriting
import DiaryDetail
import DiaryBottomSheet
import ProfileHome

public protocol DiaryHomeDependency: Dependency {
    // AppRootComponent에서 생성해서, 부모(AppRoot RIBs)로부터 받아옴
    var diaryRepository: DiaryRepository { get }
    var momentsRepository: MomentsRepository { get }
    var diaryUUIDRelay: BehaviorRelay<String> { get }
}

public final class DiaryHomeComponent: Component<DiaryHomeDependency>, ProfileHomeDependency, DiarySearchDependency, DiaryWritingDependency, DiaryHomeInteractorDependency, DiaryDetailDependency, DesignSystemDependency, DiaryBottomSheetDependency {
    
    public var diaryUUIDRelay: BehaviorRelay<String> { dependency.diaryUUIDRelay }
    public var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    public var filterResetBtnRelay: BehaviorRelay<Bool>?
    public var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    public var filteredDiaryCountRelay: BehaviorRelay<Int>?
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.

    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var momentsRepository: MomentsRepository { dependency.momentsRepository }
    
    public override init(
        dependency: DiaryHomeDependency
    ) {
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol DiaryHomeBuildable: Buildable {
    func build(
        withListener listener: DiaryHomeListener,
        diaryUUIDRelay: BehaviorRelay<String>?
    ) -> DiaryHomeRouting
}

public final class DiaryHomeBuilder: Builder<DiaryHomeDependency>, DiaryHomeBuildable {

    public override init(dependency: DiaryHomeDependency) {
        super.init(dependency: dependency)
    }

    public func build(
        withListener listener: DiaryHomeListener,
        diaryUUIDRelay: BehaviorRelay<String>?
    ) -> DiaryHomeRouting {
        let component = DiaryHomeComponent(dependency: dependency)
        
        let profileHomeBuildable = ProfileHomeBuilder(dependency: component)
        let diarySearchBuildable = DiarySearchBuilder(dependency: component)
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        let diaryDetailBuildable = DiaryDetailBuilder(dependency: component)
        let designSystemBuildable = DesignSystemBuilder(dependency: component)
        let diaryBottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        
        let viewController = DiaryHomeViewController()
        viewController.screenName = "home"
        let interactor = DiaryHomeInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        component.filteredDiaryCountRelay = interactor.filteredDiaryCountRelay
        component.filteredPlaceArrRelay = interactor.filteredPlaceArrRelay
        component.filteredWeatherArrRelay = interactor.filteredWeatherArrRelay
        component.filterResetBtnRelay = interactor.filterResetBtnRelay
        
        return DiaryHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profileHomeBuildable: profileHomeBuildable,
            diarySearchBuildable: diarySearchBuildable,
            diaryWritingBuildable: diaryWritingBuildable,
            diaryDetailBuildable: diaryDetailBuildable,
            designSystemBuildable: designSystemBuildable,
            diarybottomSheetBuildable: diaryBottomSheetBuildable
        )
    }
}
