//
//  TabsRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs

protocol TabsInteractable: Interactable {
    var router: TabsRouting? { get set }
    var listener: TabsListener? { get set }
}

protocol TabsViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TabsRouter: ViewableRouter<TabsInteractable, TabsViewControllable>, TabsRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: TabsInteractable, viewController: TabsViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
