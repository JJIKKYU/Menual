//
//  DiaryDetailBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs

protocol DiaryDetailDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryDetailComponent: Component<DiaryDetailDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryDetailBuildable: Buildable {
    func build(withListener listener: DiaryDetailListener) -> DiaryDetailRouting
}

final class DiaryDetailBuilder: Builder<DiaryDetailDependency>, DiaryDetailBuildable {

    override init(dependency: DiaryDetailDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiaryDetailListener) -> DiaryDetailRouting {
        let component = DiaryDetailComponent(dependency: dependency)
        let viewController = DiaryDetailViewController()
        let interactor = DiaryDetailInteractor(presenter: viewController)
        interactor.listener = listener
        return DiaryDetailRouter(interactor: interactor, viewController: viewController)
    }
}
