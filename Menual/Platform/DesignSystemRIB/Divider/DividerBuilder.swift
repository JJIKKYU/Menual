//
//  DividerBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol DividerDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DividerComponent: Component<DividerDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DividerBuildable: Buildable {
    func build(withListener listener: DividerListener) -> DividerRouting
}

final class DividerBuilder: Builder<DividerDependency>, DividerBuildable {

    override init(dependency: DividerDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DividerListener) -> DividerRouting {
        let component = DividerComponent(dependency: dependency)
        let viewController = DividerViewController()
        let interactor = DividerInteractor(presenter: viewController)
        interactor.listener = listener
        return DividerRouter(interactor: interactor, viewController: viewController)
    }
}
