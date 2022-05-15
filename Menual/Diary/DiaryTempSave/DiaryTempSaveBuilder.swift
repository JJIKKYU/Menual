//
//  DiaryTempSaveBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs

protocol DiaryTempSaveDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryTempSaveComponent: Component<DiaryTempSaveDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryTempSaveBuildable: Buildable {
    func build(withListener listener: DiaryTempSaveListener) -> DiaryTempSaveRouting
}

final class DiaryTempSaveBuilder: Builder<DiaryTempSaveDependency>, DiaryTempSaveBuildable {

    override init(dependency: DiaryTempSaveDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiaryTempSaveListener) -> DiaryTempSaveRouting {
        let component = DiaryTempSaveComponent(dependency: dependency)
        let viewController = DiaryTempSaveViewController()
        let interactor = DiaryTempSaveInteractor(presenter: viewController)
        interactor.listener = listener
        return DiaryTempSaveRouter(interactor: interactor, viewController: viewController)
    }
}
