//
//  CapsuleButtonBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol CapsuleButtonDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class CapsuleButtonComponent: Component<CapsuleButtonDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol CapsuleButtonBuildable: Buildable {
    func build(withListener listener: CapsuleButtonListener) -> CapsuleButtonRouting
}

final class CapsuleButtonBuilder: Builder<CapsuleButtonDependency>, CapsuleButtonBuildable {

    override init(dependency: CapsuleButtonDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: CapsuleButtonListener) -> CapsuleButtonRouting {
        let component = CapsuleButtonComponent(dependency: dependency)
        let viewController = CapsuleButtonViewController()
        let interactor = CapsuleButtonInteractor(presenter: viewController)
        interactor.listener = listener
        return CapsuleButtonRouter(interactor: interactor, viewController: viewController)
    }
}
