//
//  ProfileRestoreBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import MenualRepository

public protocol ProfileRestoreDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

public final class ProfileRestoreComponent: Component<ProfileRestoreDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

public protocol ProfileRestoreBuildable: Buildable {
    func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting
}

public final class ProfileRestoreBuilder: Builder<ProfileRestoreDependency>, ProfileRestoreBuildable {

    public override init(dependency: ProfileRestoreDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting {
        let component = ProfileRestoreComponent(dependency: dependency)
        let viewController = ProfileRestoreViewController()
        viewController.screenName = "restore"
        let interactor = ProfileRestoreInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfileRestoreRouter(interactor: interactor, viewController: viewController)
    }
}
