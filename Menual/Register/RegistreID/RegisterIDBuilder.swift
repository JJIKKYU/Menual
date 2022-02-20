//
//  RegisterIDBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterIDDependency: Dependency {
    var registerHomeBuildable: RegisterHomeBuildable { get }
}

final class RegisterIDComponent: Component<RegisterIDDependency> {

    var registerHomeBaseViewController: ViewControllable
    var registerHomeBuildable: RegisterHomeBuildable { dependency.registerHomeBuildable }
    
    init(
        dependency: RegisterIDDependency,
        registerHomeBaseViewController: ViewControllable
    ) {
        self.registerHomeBaseViewController = registerHomeBaseViewController
        super.init(dependency: dependency)
    }
    
}

// MARK: - Builder

protocol RegisterIDBuildable: Buildable {
    func build(withListener listener: RegisterIDListener) -> RegisterIDRouting
}

final class RegisterIDBuilder: Builder<RegisterIDDependency>, RegisterIDBuildable {

    override init(dependency: RegisterIDDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RegisterIDListener) -> RegisterIDRouting {
        let viewController = RegisterIDViewController()
        let component = RegisterIDComponent(dependency: dependency,
                                            registerHomeBaseViewController: viewController)
        
        let interactor = RegisterIDInteractor(
            presenter: viewController
        )
        
        interactor.listener = listener
        
        return RegisterIDRouter(
            interactor: interactor,
            viewController: viewController,
            registerHomeBuildable: component.registerHomeBuildable
        )
    }
}
