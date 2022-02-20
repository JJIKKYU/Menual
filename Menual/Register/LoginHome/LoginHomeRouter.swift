//
//  LoginHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol LoginHomeInteractable: Interactable, RegisterHomeListener {
    var router: LoginHomeRouting? { get set }
    var listener: LoginHomeListener? { get set }
}

protocol LoginHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class LoginHomeRouter: ViewableRouter<LoginHomeInteractable, LoginHomeViewControllable>, LoginHomeRouting {
    
    private let registerHomeBuildable: RegisterHomeBuildable
    
    init(
        interactor: LoginHomeInteractable,
        viewController: LoginHomeViewControllable,
        registerHomeBuildable: RegisterHomeBuildable
    ) {
        self.registerHomeBuildable = registerHomeBuildable
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachRegister() {
        let registerHome = registerHomeBuildable.build(withListener: interactor)
        print("topviewcontroller = \(viewControllable.topViewControllable)")
        attachChild(registerHome)
        // viewControllable.pushViewController(registerHome, animated: false)
    }
}
