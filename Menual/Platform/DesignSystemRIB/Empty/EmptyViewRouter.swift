//
//  EmptyViewRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import RIBs

protocol EmptyViewInteractable: Interactable {
    var router: EmptyViewRouting? { get set }
    var listener: EmptyViewListener? { get set }
}

protocol EmptyViewViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class EmptyViewRouter: ViewableRouter<EmptyViewInteractable, EmptyViewViewControllable>, EmptyViewRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: EmptyViewInteractable, viewController: EmptyViewViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
