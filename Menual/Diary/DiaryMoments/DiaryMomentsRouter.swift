//
//  DiaryMomentsRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/03.
//

import RIBs

protocol DiaryMomentsInteractable: Interactable {
    var router: DiaryMomentsRouting? { get set }
    var listener: DiaryMomentsListener? { get set }
}

protocol DiaryMomentsViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryMomentsRouter: ViewableRouter<DiaryMomentsInteractable, DiaryMomentsViewControllable>, DiaryMomentsRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryMomentsInteractable, viewController: DiaryMomentsViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
