//
//  FABRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import RIBs

protocol FABInteractable: Interactable {
    var router: FABRouting? { get set }
    var listener: FABListener? { get set }
}

protocol FABViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FABRouter: ViewableRouter<FABInteractable, FABViewControllable>, FABRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: FABInteractable, viewController: FABViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
