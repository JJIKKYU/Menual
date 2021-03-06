//
//  DiaryHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs

protocol DiaryHomeDependency: Dependency {
    // AppRootComponent에서 생성해서, 부모(AppRoot RIBs)로부터 받아옴
    var diaryRepository: DiaryRepository { get }
}

final class DiaryHomeComponent: Component<DiaryHomeDependency>, ProfileHomeDependency, DiarySearchDependency, DiaryMomentsDependency, DiaryWritingDependency, DiaryHomeInteractorDependency, DiaryDetailDependency, DesignSystemDependency {
    
    // 부모(AppRoot)에서 받아온 걸 받아서 사용만 함.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
    
    override init(
        dependency: DiaryHomeDependency
    ) {
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol DiaryHomeBuildable: Buildable {
    func build(withListener listener: DiaryHomeListener) -> DiaryHomeRouting
}

final class DiaryHomeBuilder: Builder<DiaryHomeDependency>, DiaryHomeBuildable {

    override init(dependency: DiaryHomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiaryHomeListener) -> DiaryHomeRouting {
        let component = DiaryHomeComponent(dependency: dependency)
        
        let profileHomeBuildable = ProfileHomeBuilder(dependency: component)
        let diarySearchBuildable = DiarySearchBuilder(dependency: component)
        let diaryMomentsBuildable = DiaryMomentsBuilder(dependency: component)
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        let diaryDetailBuildable = DiaryDetailBuilder(dependency: component)
        let designSystemBuildable = DesignSystemBuilder(dependency: component)
        
        let viewController = DiaryHomeViewController()
        let interactor = DiaryHomeInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        
        return DiaryHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profileHomeBuildable: profileHomeBuildable,
            diarySearchBuildable: diarySearchBuildable,
            diaryMomentsBuildable: diaryMomentsBuildable,
            diaryWritingBuildable: diaryWritingBuildable,
            diaryDetailBuildable: diaryDetailBuildable,
            designSystemBuildable: designSystemBuildable
        )
    }
}
