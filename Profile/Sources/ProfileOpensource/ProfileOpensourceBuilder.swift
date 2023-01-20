//
//  ProfileOpensourceBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/27.
//

import RIBs

public protocol ProfileOpensourceDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

public final class ProfileOpensourceComponent: Component<ProfileOpensourceDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

public protocol ProfileOpensourceBuildable: Buildable {
    func build(withListener listener: ProfileOpensourceListener) -> ProfileOpensourceRouting
}

public final class ProfileOpensourceBuilder: Builder<ProfileOpensourceDependency>, ProfileOpensourceBuildable {

    public override init(dependency: ProfileOpensourceDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileOpensourceListener) -> ProfileOpensourceRouting {
        let component = ProfileOpensourceComponent(dependency: dependency)
        let viewController = ProfileOpensourceViewController()
        let interactor = ProfileOpensourceInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfileOpensourceRouter(interactor: interactor, viewController: viewController)
    }
}
