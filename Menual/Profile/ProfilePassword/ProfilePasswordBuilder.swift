//
//  ProfilePasswordBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs

protocol ProfilePasswordDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class ProfilePasswordComponent: Component<ProfilePasswordDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol ProfilePasswordBuildable: Buildable {
    func build(withListener listener: ProfilePasswordListener) -> ProfilePasswordRouting
}

final class ProfilePasswordBuilder: Builder<ProfilePasswordDependency>, ProfilePasswordBuildable {

    override init(dependency: ProfilePasswordDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfilePasswordListener) -> ProfilePasswordRouting {
        let component = ProfilePasswordComponent(dependency: dependency)
        let viewController = ProfilePasswordViewController()
        let interactor = ProfilePasswordInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfilePasswordRouter(interactor: interactor, viewController: viewController)
    }
}
