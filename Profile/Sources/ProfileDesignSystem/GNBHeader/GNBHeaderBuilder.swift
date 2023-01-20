//
//  GNBHeaderBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol GNBHeaderDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class GNBHeaderComponent: Component<GNBHeaderDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol GNBHeaderBuildable: Buildable {
    func build(withListener listener: GNBHeaderListener) -> GNBHeaderRouting
}

final class GNBHeaderBuilder: Builder<GNBHeaderDependency>, GNBHeaderBuildable {

    override init(dependency: GNBHeaderDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: GNBHeaderListener) -> GNBHeaderRouting {
        let component = GNBHeaderComponent(dependency: dependency)
        let viewController = GNBHeaderViewController()
        let interactor = GNBHeaderInteractor(presenter: viewController)
        interactor.listener = listener
        return GNBHeaderRouter(interactor: interactor, viewController: viewController)
    }
}
