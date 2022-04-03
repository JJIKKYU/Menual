//
//  DiaryMomentsBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/03.
//

import RIBs

protocol DiaryMomentsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryMomentsComponent: Component<DiaryMomentsDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryMomentsBuildable: Buildable {
    func build(withListener listener: DiaryMomentsListener) -> DiaryMomentsRouting
}

final class DiaryMomentsBuilder: Builder<DiaryMomentsDependency>, DiaryMomentsBuildable {

    override init(dependency: DiaryMomentsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiaryMomentsListener) -> DiaryMomentsRouting {
        let component = DiaryMomentsComponent(dependency: dependency)
        let viewController = DiaryMomentsViewController()
        let interactor = DiaryMomentsInteractor(presenter: viewController)
        interactor.listener = listener
        return DiaryMomentsRouter(interactor: interactor, viewController: viewController)
    }
}
