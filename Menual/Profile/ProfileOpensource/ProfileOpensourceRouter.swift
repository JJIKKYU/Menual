//
//  ProfileOpensourceRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/11/27.
//

import RIBs

protocol ProfileOpensourceInteractable: Interactable {
    var router: ProfileOpensourceRouting? { get set }
    var listener: ProfileOpensourceListener? { get set }
}

protocol ProfileOpensourceViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileOpensourceRouter: ViewableRouter<ProfileOpensourceInteractable, ProfileOpensourceViewControllable>, ProfileOpensourceRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileOpensourceInteractable, viewController: ProfileOpensourceViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
