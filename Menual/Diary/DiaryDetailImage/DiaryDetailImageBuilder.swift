//
//  DiaryDetailImageBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs
import RxRelay
import Foundation

protocol DiaryDetailImageDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DiaryDetailImageComponent: Component<DiaryDetailImageDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryDetailImageBuildable: Buildable {
    func build(
        withListener listener: DiaryDetailImageListener,
        imageDataRelay: BehaviorRelay<Data>
    ) -> DiaryDetailImageRouting
}

final class DiaryDetailImageBuilder: Builder<DiaryDetailImageDependency>, DiaryDetailImageBuildable {

    override init(dependency: DiaryDetailImageDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryDetailImageListener,
        imageDataRelay: BehaviorRelay<Data>
    ) -> DiaryDetailImageRouting {
        let component = DiaryDetailImageComponent(dependency: dependency)
        let viewController = DiaryDetailImageViewController()
        let interactor = DiaryDetailImageInteractor(
            presenter: viewController,
            imageDataRelay: imageDataRelay
        )
        interactor.listener = listener
        return DiaryDetailImageRouter(interactor: interactor, viewController: viewController)
    }
}
