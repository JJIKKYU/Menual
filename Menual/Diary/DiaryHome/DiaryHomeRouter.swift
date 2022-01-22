//
//  DiaryHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs

protocol DiaryHomeInteractable: Interactable {
    var router: DiaryHomeRouting? { get set }
    var listener: DiaryHomeListener? { get set }
}

protocol DiaryHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryHomeRouter: ViewableRouter<DiaryHomeInteractable, DiaryHomeViewControllable>, DiaryHomeRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryHomeInteractable, viewController: DiaryHomeViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
