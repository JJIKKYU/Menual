//
//  ProfileRestoreConfirmRouter.swift
//  Menual
//
//  Created by 정진균 on 2023/02/26.
//

import RIBs

public protocol ProfileRestoreConfirmInteractable: Interactable {
    var router: ProfileRestoreConfirmRouting? { get set }
    var listener: ProfileRestoreConfirmListener? { get set }
}

public protocol ProfileRestoreConfirmViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileRestoreConfirmRouter: ViewableRouter<ProfileRestoreConfirmInteractable, ProfileRestoreConfirmViewControllable>, ProfileRestoreConfirmRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileRestoreConfirmInteractable, viewController: ProfileRestoreConfirmViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
