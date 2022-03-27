//
//  DiarySearchRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs

protocol DiarySearchInteractable: Interactable {
    var router: DiarySearchRouting? { get set }
    var listener: DiarySearchListener? { get set }
}

protocol DiarySearchViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiarySearchRouter: ViewableRouter<DiarySearchInteractable, DiarySearchViewControllable>, DiarySearchRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiarySearchInteractable, viewController: DiarySearchViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
