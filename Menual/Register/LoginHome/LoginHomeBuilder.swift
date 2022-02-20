//
//  LoginHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol LoginHomeDependency: Dependency {
    var registerHomeBuildable: RegisterHomeBuildable { get }
    var registerHomeBaseController: ViewControllable { get }
}

final class LoginHomeComponent: Component<LoginHomeDependency>, RegisterHomeDependency {
    var registerHomeBaseController: ViewControllable { dependency.registerHomeBaseController }
    var registerHomeBuildable: RegisterHomeBuildable { dependency.registerHomeBuildable }
}

// MARK: - Builder

protocol LoginHomeBuildable: Buildable {
    func build(withListener listener: LoginHomeListener) -> LoginHomeRouting
}

final class LoginHomeBuilder: Builder<LoginHomeDependency>, LoginHomeBuildable {

    override init(dependency: LoginHomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: LoginHomeListener) -> LoginHomeRouting {
        let component = LoginHomeComponent(dependency: dependency)
        
        let registerHomeBuildable = RegisterHomeBuilder(dependency: component)
        
        let viewController = LoginHomeViewController()
        let interactor = LoginHomeInteractor(presenter: viewController)
        
        interactor.listener = listener
        
        return LoginHomeRouter(
            interactor: interactor,
            viewController: viewController,
            registerHomeBuildable: registerHomeBuildable
        )
    }
}
