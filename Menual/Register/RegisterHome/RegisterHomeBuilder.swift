//
//  RegisterHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterHomeDependency: Dependency {
    var registerHomeBaseController: ViewControllable { get }
    var registerHomeBuildable: RegisterHomeBuildable { get }
}

final class RegisterHomeComponent: Component<RegisterHomeDependency>, RegisterIDDependency {
    var registerHomeBuildable: RegisterHomeBuildable { dependency.registerHomeBuildable }

    // TODO: Make sure to convert the variable into lower-camelcase.
    fileprivate var RegisterHomeBaseViewController: ViewControllable {
        return dependency.registerHomeBaseController
    }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol RegisterHomeBuildable: Buildable {
    func build(withListener listener: RegisterHomeListener) -> RegisterHomeRouting
}

final class RegisterHomeBuilder: Builder<RegisterHomeDependency>, RegisterHomeBuildable {

    override init(dependency: RegisterHomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RegisterHomeListener) -> RegisterHomeRouting {
        
        let component = RegisterHomeComponent(dependency: dependency)

        let registerIDBuildable = RegisterIDBuilder(dependency: component)
        
        let interactor = RegisterHomeInteractor()
        interactor.listener = listener
        
        return RegisterHomeRouter(
            interactor: interactor,
            viewController: component.RegisterHomeBaseViewController,
            registerIDBuilable: registerIDBuildable
        )
    }
}
