//
//  BoxButtonBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol BoxButtonDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class BoxButtonComponent: Component<BoxButtonDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol BoxButtonBuildable: Buildable {
    func build(withListener listener: BoxButtonListener) -> BoxButtonRouting
}

final class BoxButtonBuilder: Builder<BoxButtonDependency>, BoxButtonBuildable {

    override init(dependency: BoxButtonDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: BoxButtonListener) -> BoxButtonRouting {
        let component = BoxButtonComponent(dependency: dependency)
        let viewController = BoxButtonViewController()
        let interactor = BoxButtonInteractor(presenter: viewController)
        interactor.listener = listener
        return BoxButtonRouter(interactor: interactor, viewController: viewController)
    }
}
