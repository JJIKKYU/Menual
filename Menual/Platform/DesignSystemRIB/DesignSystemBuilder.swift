//
//  DesignSystemBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol DesignSystemDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class DesignSystemComponent: Component<DesignSystemDependency>, BoxButtonDependency, GNBHeaderDependency, ListHeaderDependency, MomentsDependency, DividerDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DesignSystemBuildable: Buildable {
    func build(withListener listener: DesignSystemListener) -> DesignSystemRouting
}

final class DesignSystemBuilder: Builder<DesignSystemDependency>, DesignSystemBuildable {

    override init(dependency: DesignSystemDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DesignSystemListener) -> DesignSystemRouting {
        let component = DesignSystemComponent(dependency: dependency)
        
        let boxButtonBuildable = BoxButtonBuilder(dependency: component)
        let gnbHeaderBuildable = GNBHeaderBuilder(dependency: component)
        let listHeaderBuildable = ListHeaderBuilder(dependency: component)
        let momentsBuildable = MomentsBuilder(dependency: component)
        let dividerBuildable = DividerBuilder(dependency: component)
        
        let viewController = DesignSystemViewController()
        let interactor = DesignSystemInteractor(presenter: viewController)
        interactor.listener = listener
        return DesignSystemRouter(
            interactor: interactor,
            viewController: viewController,
            boxButtonBuildable: boxButtonBuildable,
            gnbHeaderBuildable: gnbHeaderBuildable,
            listHeaderBuildable: listHeaderBuildable,
            momentsBuildable: momentsBuildable,
            dividerBuildable: dividerBuildable
        )
    }
}
