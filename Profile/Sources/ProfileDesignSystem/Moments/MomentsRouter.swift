//
//  MomentsRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs

protocol MomentsInteractable: Interactable {
    var router: MomentsRouting? { get set }
    var listener: MomentsListener? { get set }
}

protocol MomentsViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MomentsRouter: ViewableRouter<MomentsInteractable, MomentsViewControllable>, MomentsRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: MomentsInteractable, viewController: MomentsViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
