//
//  DiaryDetailImageBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs
import RxRelay
import Foundation

public protocol DiaryDetailImageDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

public final class DiaryDetailImageComponent: Component<DiaryDetailImageDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

public protocol DiaryDetailImageBuildable: Buildable {
    func build(
        withListener listener: DiaryDetailImageListener,
        imagesDataRelay: BehaviorRelay<[Data]>,
        selectedIndex: Int
    ) -> DiaryDetailImageRouting
}

public final class DiaryDetailImageBuilder: Builder<DiaryDetailImageDependency>, DiaryDetailImageBuildable {

    public override init(dependency: DiaryDetailImageDependency) {
        super.init(dependency: dependency)
    }

    public func build(
        withListener listener: DiaryDetailImageListener,
        imagesDataRelay: BehaviorRelay<[Data]>,
        selectedIndex: Int
    ) -> DiaryDetailImageRouting {
        let component = DiaryDetailImageComponent(dependency: dependency)
        let viewController = DiaryDetailImageViewController()
        let interactor = DiaryDetailImageInteractor(
            presenter: viewController,
            imagesDataRelay: imagesDataRelay,
            selectedIndex: selectedIndex
        )
        interactor.listener = listener
        return DiaryDetailImageRouter(interactor: interactor, viewController: viewController)
    }
}
