//
//  DesignSystemRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol DesignSystemInteractable: Interactable {
    var router: DesignSystemRouting? { get set }
    var listener: DesignSystemListener? { get set }
}

protocol DesignSystemViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DesignSystemRouter: ViewableRouter<DesignSystemInteractable, DesignSystemViewControllable>, DesignSystemRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DesignSystemInteractable, viewController: DesignSystemViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
