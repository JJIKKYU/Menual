//
//  DiaryWritingBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs

protocol DiaryWritingDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingComponent: Component<DiaryWritingDependency>, DiaryWritingInteractorDependency {

    var diaryRepository: DiaryRepository { dependency.diaryRepository }
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
        let interactor = DiaryWritingInteractor(
            presenter: viewController,
        dependency: component
        )
        interactor.listener = listener
        return DiaryWritingRouter(interactor: interactor, viewController: viewController)
    }
}
