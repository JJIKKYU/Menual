//
//  EmptyViewBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import RIBs

protocol EmptyViewDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class EmptyViewComponent: Component<EmptyViewDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol EmptyViewBuildable: Buildable {
    func build(withListener listener: EmptyViewListener) -> EmptyViewRouting
}

final class EmptyViewBuilder: Builder<EmptyViewDependency>, EmptyViewBuildable {

    override init(dependency: EmptyViewDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: EmptyViewListener) -> EmptyViewRouting {
        let component = EmptyViewComponent(dependency: dependency)
        let viewController = EmptyViewViewController()
        let interactor = EmptyViewInteractor(presenter: viewController)
        interactor.listener = listener
        return EmptyViewRouter(interactor: interactor, viewController: viewController)
    }
}
