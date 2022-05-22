//
//  MomentsBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol MomentsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class MomentsComponent: Component<MomentsDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol MomentsBuildable: Buildable {
    func build(withListener listener: MomentsListener) -> MomentsRouting
}

final class MomentsBuilder: Builder<MomentsDependency>, MomentsBuildable {

    override init(dependency: MomentsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MomentsListener) -> MomentsRouting {
        let component = MomentsComponent(dependency: dependency)
        let viewController = MomentsViewController()
        let interactor = MomentsInteractor(presenter: viewController)
        interactor.listener = listener
        return MomentsRouter(interactor: interactor, viewController: viewController)
    }
}
