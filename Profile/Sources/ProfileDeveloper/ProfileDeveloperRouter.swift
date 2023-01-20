//
//  ProfileDeveloperRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs

protocol ProfileDeveloperInteractable: Interactable {
    var router: ProfileDeveloperRouting? { get set }
    var listener: ProfileDeveloperListener? { get set }
}

protocol ProfileDeveloperViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileDeveloperRouter: ViewableRouter<ProfileDeveloperInteractable, ProfileDeveloperViewControllable>, ProfileDeveloperRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileDeveloperInteractable, viewController: ProfileDeveloperViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
