//
//  DiaryBottomSheetRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs

protocol DiaryBottomSheetInteractable: Interactable {
    var router: DiaryBottomSheetRouting? { get set }
    var listener: DiaryBottomSheetListener? { get set }
}

protocol DiaryBottomSheetViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryBottomSheetRouter: ViewableRouter<DiaryBottomSheetInteractable, DiaryBottomSheetViewControllable>, DiaryBottomSheetRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: DiaryBottomSheetInteractable, viewController: DiaryBottomSheetViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
