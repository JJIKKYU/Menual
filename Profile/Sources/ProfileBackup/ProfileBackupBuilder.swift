//
//  ProfileBackupBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs

protocol ProfileBackupDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class ProfileBackupComponent: Component<ProfileBackupDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol ProfileBackupBuildable: Buildable {
    func build(withListener listener: ProfileBackupListener) -> ProfileBackupRouting
}

final class ProfileBackupBuilder: Builder<ProfileBackupDependency>, ProfileBackupBuildable {

    override init(dependency: ProfileBackupDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfileBackupListener) -> ProfileBackupRouting {
        let component = ProfileBackupComponent(dependency: dependency)
        let viewController = ProfileBackupViewController()
        let interactor = ProfileBackupInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfileBackupRouter(interactor: interactor, viewController: viewController)
    }
}
