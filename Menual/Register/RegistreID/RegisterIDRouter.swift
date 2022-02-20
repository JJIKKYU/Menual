//
//  RegisterIDRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterIDInteractable: Interactable, RegisterHomeListener {
    var router: RegisterIDRouting? { get set }
    var listener: RegisterIDListener? { get set }
}

protocol RegisterIDViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class RegisterIDRouter: ViewableRouter<RegisterIDInteractable, RegisterIDViewControllable>, RegisterIDRouting {
    
    private let registerHomeBuildable: RegisterHomeBuildable
    private var registerHomeRouting: Routing?

    init(
        interactor: RegisterIDInteractable,
        viewController: RegisterIDViewControllable,
        registerHomeBuildable: RegisterHomeBuildable
    ) {
        self.registerHomeBuildable = registerHomeBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
