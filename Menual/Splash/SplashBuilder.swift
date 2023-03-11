//
//  SplashBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/15.
//

import RIBs

protocol SplashDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class SplashComponent: Component<SplashDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol SplashBuildable: Buildable {
    func build(withListener listener: SplashListener) -> SplashRouting
}

final class SplashBuilder: Builder<SplashDependency>, SplashBuildable {

    override init(dependency: SplashDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SplashListener) -> SplashRouting {
        let component = SplashComponent(dependency: dependency)
        let viewController = SplashViewController()
        let interactor = SplashInteractor(presenter: viewController)
        interactor.listener = listener
        return SplashRouter(interactor: interactor, viewController: viewController)
    }
}
