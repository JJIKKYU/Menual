//
//  ProfileHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs

protocol ProfileHomeDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class ProfileHomeComponent: Component<ProfileHomeDependency>, ProfilePasswordDependency, ProfileDeveloperDependency, ProfileHomeInteractorDependency, ProfileOpensourceDependency {

    var diaryRepository: DiaryRepository { dependency.diaryRepository }
}

// MARK: - Builder

protocol ProfileHomeBuildable: Buildable {
    func build(
        withListener listener: ProfileHomeListener
    ) -> ProfileHomeRouting
}

final class ProfileHomeBuilder: Builder<ProfileHomeDependency>, ProfileHomeBuildable {

    override init(dependency: ProfileHomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfileHomeListener) -> ProfileHomeRouting {
        let component = ProfileHomeComponent(dependency: dependency)
        
        let profilePasswordBuildable = ProfilePasswordBuilder(dependency: component)
        let profileDveloperBuildable = ProfileDeveloperBuilder(dependency: component)
        let profileOpensourceBuildable = ProfileOpensourceBuilder(dependency: component)
        
        let viewController = ProfileHomeViewController()
        viewController.screenName = "profile"
        let interactor = ProfileHomeInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener

        return ProfileHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profilePasswordBuildable: profilePasswordBuildable,
            profileDeveloperBuildable: profileDveloperBuildable,
            profileOpensourceBuildable: profileOpensourceBuildable
        )
    }
}
