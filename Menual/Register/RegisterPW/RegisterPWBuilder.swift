//
//  RegisterPWBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterPWDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class RegisterPWComponent: Component<RegisterPWDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol RegisterPWBuildable: Buildable {
    func build(withListener listener: RegisterPWListener) -> RegisterPWRouting
}

final class RegisterPWBuilder: Builder<RegisterPWDependency>, RegisterPWBuildable {

    override init(dependency: RegisterPWDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RegisterPWListener) -> RegisterPWRouting {
        let component = RegisterPWComponent(dependency: dependency)
        let viewController = RegisterPWViewController()
        let interactor = RegisterPWInteractor(presenter: viewController)
        interactor.listener = listener
        return RegisterPWRouter(interactor: interactor, viewController: viewController)
    }
}
