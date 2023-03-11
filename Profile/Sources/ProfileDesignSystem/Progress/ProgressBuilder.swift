//
//  ProgressBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/03/01.
//

import RIBs

protocol ProgressDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class ProgressComponent: Component<ProgressDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol ProgressBuildable: Buildable {
    func build(withListener listener: ProgressListener) -> ProgressRouting
}

final class ProgressBuilder: Builder<ProgressDependency>, ProgressBuildable {

    override init(dependency: ProgressDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProgressListener) -> ProgressRouting {
        let component = ProgressComponent(dependency: dependency)
        let viewController = ProgressViewController()
        let interactor = ProgressInteractor(presenter: viewController)
        interactor.listener = listener
        return ProgressRouter(interactor: interactor, viewController: viewController)
    }
}
