//
//  GNBHeaderRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol GNBHeaderInteractable: Interactable {
    var router: GNBHeaderRouting? { get set }
    var listener: GNBHeaderListener? { get set }
}

protocol GNBHeaderViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class GNBHeaderRouter: ViewableRouter<GNBHeaderInteractable, GNBHeaderViewControllable>, GNBHeaderRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: GNBHeaderInteractable, viewController: GNBHeaderViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
