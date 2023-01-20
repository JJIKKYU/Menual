//
//  ProfilePasswordRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs

protocol ProfilePasswordInteractable: Interactable {
    var router: ProfilePasswordRouting? { get set }
    var listener: ProfilePasswordListener? { get set }
}

protocol ProfilePasswordViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfilePasswordRouter: ViewableRouter<ProfilePasswordInteractable, ProfilePasswordViewControllable>, ProfilePasswordRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfilePasswordInteractable, viewController: ProfilePasswordViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
