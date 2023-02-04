//
//  ProfileRestoreBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs

protocol ProfileRestoreDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class ProfileRestoreComponent: Component<ProfileRestoreDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol ProfileRestoreBuildable: Buildable {
    func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting
}

final class ProfileRestoreBuilder: Builder<ProfileRestoreDependency>, ProfileRestoreBuildable {

    override init(dependency: ProfileRestoreDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting {
        let component = ProfileRestoreComponent(dependency: dependency)
        let viewController = ProfileRestoreViewController()
        let interactor = ProfileRestoreInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfileRestoreRouter(interactor: interactor, viewController: viewController)
    }
}
