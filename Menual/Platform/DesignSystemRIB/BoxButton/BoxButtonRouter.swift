//
//  BoxButtonRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol BoxButtonInteractable: Interactable {
    var router: BoxButtonRouting? { get set }
    var listener: BoxButtonListener? { get set }
}

protocol BoxButtonViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BoxButtonRouter: ViewableRouter<BoxButtonInteractable, BoxButtonViewControllable>, BoxButtonRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: BoxButtonInteractable, viewController: BoxButtonViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
