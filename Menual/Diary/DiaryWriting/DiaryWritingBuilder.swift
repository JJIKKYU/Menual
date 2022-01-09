//
//  DiaryWritingBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs

protocol DiaryWritingDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryWritingComponent: Component<DiaryWritingDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryWritingBuildable: Buildable {
    func build(withListener listener: DiaryWritingListener) -> DiaryWritingRouting
}

final class DiaryWritingBuilder: Builder<DiaryWritingDependency>, DiaryWritingBuildable {

    override init(dependency: DiaryWritingDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiaryWritingListener) -> DiaryWritingRouting {
        let component = DiaryWritingComponent(dependency: dependency)
        let viewController = DiaryWritingViewController()
        let interactor = DiaryWritingInteractor(presenter: viewController)
        interactor.listener = listener
        return DiaryWritingRouter(interactor: interactor, viewController: viewController)
    }
}
