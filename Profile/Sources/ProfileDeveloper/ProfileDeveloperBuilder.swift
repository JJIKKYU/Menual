//
//  ProfileDeveloperBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import MenualRepository

public protocol ProfileDeveloperDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

public final class ProfileDeveloperComponent: Component<ProfileDeveloperDependency>, ProfileDeveloperInteractorDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
}


// MARK: - Builder

public protocol ProfileDeveloperBuildable: Buildable {
    func build(withListener listener: ProfileDeveloperListener) -> ProfileDeveloperRouting
}

public final class ProfileDeveloperBuilder: Builder<ProfileDeveloperDependency>, ProfileDeveloperBuildable {

    public override init(dependency: ProfileDeveloperDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileDeveloperListener) -> ProfileDeveloperRouting {
        let component = ProfileDeveloperComponent(dependency: dependency)
        let viewController = ProfileDeveloperViewController()
        let interactor = ProfileDeveloperInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        return ProfileDeveloperRouter(interactor: interactor, viewController: viewController)
    }
}
