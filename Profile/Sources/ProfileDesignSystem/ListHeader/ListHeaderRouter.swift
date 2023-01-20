//
//  ListHeaderRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol ListHeaderInteractable: Interactable {
    var router: ListHeaderRouting? { get set }
    var listener: ListHeaderListener? { get set }
}

protocol ListHeaderViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ListHeaderRouter: ViewableRouter<ListHeaderInteractable, ListHeaderViewControllable>, ListHeaderRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ListHeaderInteractable, viewController: ListHeaderViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
