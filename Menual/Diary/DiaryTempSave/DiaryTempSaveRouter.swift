//
//  DiaryTempSaveRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs

protocol DiaryTempSaveInteractable: Interactable {
    var router: DiaryTempSaveRouting? { get set }
    var listener: DiaryTempSaveListener? { get set }
}

protocol DiaryTempSaveViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryTempSaveRouter: ViewableRouter<DiaryTempSaveInteractable, DiaryTempSaveViewControllable>, DiaryTempSaveRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryTempSaveInteractable, viewController: DiaryTempSaveViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
