//
//  DiarySearchBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs

protocol DiarySearchDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiarySearchComponent: Component<DiarySearchDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiarySearchBuildable: Buildable {
    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting
}

final class DiarySearchBuilder: Builder<DiarySearchDependency>, DiarySearchBuildable {

    override init(dependency: DiarySearchDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting {
        let component = DiarySearchComponent(dependency: dependency)
        let viewController = DiarySearchViewController()
        let interactor = DiarySearchInteractor(presenter: viewController)
        interactor.listener = listener
        return DiarySearchRouter(interactor: interactor, viewController: viewController)
    }
}
