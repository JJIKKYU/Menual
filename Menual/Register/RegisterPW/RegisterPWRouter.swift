//
//  RegisterPWRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterPWInteractable: Interactable {
    var router: RegisterPWRouting? { get set }
    var listener: RegisterPWListener? { get set }
}

protocol RegisterPWViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RegisterPWRouter: ViewableRouter<RegisterPWInteractable, RegisterPWViewControllable>, RegisterPWRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: RegisterPWInteractable, viewController: RegisterPWViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
