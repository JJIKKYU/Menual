//
//  DiaryDetailImageRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs

protocol DiaryDetailImageInteractable: Interactable {
    var router: DiaryDetailImageRouting? { get set }
    var listener: DiaryDetailImageListener? { get set }
}

protocol DiaryDetailImageViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryDetailImageRouter: ViewableRouter<DiaryDetailImageInteractable, DiaryDetailImageViewControllable>, DiaryDetailImageRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryDetailImageInteractable, viewController: DiaryDetailImageViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
