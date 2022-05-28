//
//  FABBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import RIBs

protocol FABDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class FABComponent: Component<FABDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol FABBuildable: Buildable {
    func build(withListener listener: FABListener) -> FABRouting
}

final class FABBuilder: Builder<FABDependency>, FABBuildable {

    override init(dependency: FABDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: FABListener) -> FABRouting {
        let component = FABComponent(dependency: dependency)
        let viewController = FABViewController()
        let interactor = FABInteractor(presenter: viewController)
        interactor.listener = listener
        return FABRouter(interactor: interactor, viewController: viewController)
    }
}
