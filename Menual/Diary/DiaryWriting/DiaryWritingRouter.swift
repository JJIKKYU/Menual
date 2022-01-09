//
//  DiaryWritingRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs

protocol DiaryWritingInteractable: Interactable {
    var router: DiaryWritingRouting? { get set }
    var listener: DiaryWritingListener? { get set }
}

protocol DiaryWritingViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryWritingRouter: ViewableRouter<DiaryWritingInteractable, DiaryWritingViewControllable>, DiaryWritingRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryWritingInteractable, viewController: DiaryWritingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
