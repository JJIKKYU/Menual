//
//  ListHeaderBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol ListHeaderDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class ListHeaderComponent: Component<ListHeaderDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol ListHeaderBuildable: Buildable {
    func build(withListener listener: ListHeaderListener) -> ListHeaderRouting
}

final class ListHeaderBuilder: Builder<ListHeaderDependency>, ListHeaderBuildable {

    override init(dependency: ListHeaderDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ListHeaderListener) -> ListHeaderRouting {
        let component = ListHeaderComponent(dependency: dependency)
        let viewController = ListHeaderViewController()
        let interactor = ListHeaderInteractor(presenter: viewController)
        interactor.listener = listener
        return ListHeaderRouter(interactor: interactor, viewController: viewController)
    }
}
