//
//  DividerRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol DividerInteractable: Interactable {
    var router: DividerRouting? { get set }
    var listener: DividerListener? { get set }
}

protocol DividerViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DividerRouter: ViewableRouter<DividerInteractable, DividerViewControllable>, DividerRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DividerInteractable, viewController: DividerViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
