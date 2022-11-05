//
//  MetaDataBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import RIBs

protocol MetaDataDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class MetaDataComponent: Component<MetaDataDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol MetaDataBuildable: Buildable {
    func build(withListener listener: MetaDataListener) -> MetaDataRouting
}

final class MetaDataBuilder: Builder<MetaDataDependency>, MetaDataBuildable {

    override init(dependency: MetaDataDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MetaDataListener) -> MetaDataRouting {
        let component = MetaDataComponent(dependency: dependency)
        let viewController = MetaDataViewController()
        let interactor = MetaDataInteractor(presenter: viewController)
        interactor.listener = listener
        return MetaDataRouter(interactor: interactor, viewController: viewController)
    }
}
