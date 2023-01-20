//
//  TabsBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs

protocol TabsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class TabsComponent: Component<TabsDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol TabsBuildable: Buildable {
    func build(withListener listener: TabsListener) -> TabsRouting
}

final class TabsBuilder: Builder<TabsDependency>, TabsBuildable {

    override init(dependency: TabsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TabsListener) -> TabsRouting {
        let component = TabsComponent(dependency: dependency)
        let viewController = TabsViewController()
        let interactor = TabsInteractor(presenter: viewController)
        interactor.listener = listener
        return TabsRouter(interactor: interactor, viewController: viewController)
    }
}
