//
//  PaginationBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs

protocol PaginationDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class PaginationComponent: Component<PaginationDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol PaginationBuildable: Buildable {
    func build(withListener listener: PaginationListener) -> PaginationRouting
}

final class PaginationBuilder: Builder<PaginationDependency>, PaginationBuildable {

    override init(dependency: PaginationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PaginationListener) -> PaginationRouting {
        let component = PaginationComponent(dependency: dependency)
        let viewController = PaginationViewController()
        let interactor = PaginationInteractor(presenter: viewController)
        interactor.listener = listener
        return PaginationRouter(interactor: interactor, viewController: viewController)
    }
}
