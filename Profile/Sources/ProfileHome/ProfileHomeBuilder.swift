//
//  ProfileHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import MenualRepository
import ProfileOpensource
import ProfilePassword
import ProfileDeveloper

public protocol ProfileHomeDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

public final class ProfileHomeComponent: Component<ProfileHomeDependency>, ProfilePasswordDependency, ProfileDeveloperDependency, ProfileHomeInteractorDependency, ProfileOpensourceDependency {

    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
}

// MARK: - Builder

public protocol ProfileHomeBuildable: Buildable {
    func build(
        withListener listener: ProfileHomeListener
    ) -> ProfileHomeRouting
}

public final class ProfileHomeBuilder: Builder<ProfileHomeDependency>, ProfileHomeBuildable {

    public override init(dependency: ProfileHomeDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileHomeListener) -> ProfileHomeRouting {
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
