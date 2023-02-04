//
//  ProfileRestoreRouter.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs

protocol ProfileRestoreInteractable: Interactable {
    var router: ProfileRestoreRouting? { get set }
    var listener: ProfileRestoreListener? { get set }
}

protocol ProfileRestoreViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileRestoreRouter: ViewableRouter<ProfileRestoreInteractable, ProfileRestoreViewControllable>, ProfileRestoreRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileRestoreInteractable, viewController: ProfileRestoreViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
