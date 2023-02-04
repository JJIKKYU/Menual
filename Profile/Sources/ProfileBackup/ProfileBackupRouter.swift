//
//  ProfileBackupRouter.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs

protocol ProfileBackupInteractable: Interactable {
    var router: ProfileBackupRouting? { get set }
    var listener: ProfileBackupListener? { get set }
}

protocol ProfileBackupViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileBackupRouter: ViewableRouter<ProfileBackupInteractable, ProfileBackupViewControllable>, ProfileBackupRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileBackupInteractable, viewController: ProfileBackupViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
