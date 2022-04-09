//
//  DiaryHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs

protocol DiaryHomeDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryHomeComponent: Component<DiaryHomeDependency>, ProfileHomeDependency, DiarySearchDependency, DiaryMomentsDependency, DiaryWritingDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
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
        
        let viewController = DiaryHomeViewController()
        let interactor = DiaryHomeInteractor(presenter: viewController)
        interactor.listener = listener
        
        return DiaryHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profileHomeBuildable: profileHomeBuildable,
            diarySearchBuildable: diarySearchBuildable,
            diaryMomentsBuildable: diaryMomentsBuildable,
            diaryWritingBuildable: diaryWritingBuildable
        )
    }
}
