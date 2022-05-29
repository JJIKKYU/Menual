//
//  PaginationRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs

protocol PaginationInteractable: Interactable {
    var router: PaginationRouting? { get set }
    var listener: PaginationListener? { get set }
}

protocol PaginationViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaginationRouter: ViewableRouter<PaginationInteractable, PaginationViewControllable>, PaginationRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: PaginationInteractable, viewController: PaginationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
