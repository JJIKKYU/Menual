//
//  NumberPadRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs

protocol NumberPadInteractable: Interactable {
    var router: NumberPadRouting? { get set }
    var listener: NumberPadListener? { get set }
}

protocol NumberPadViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NumberPadRouter: ViewableRouter<NumberPadInteractable, NumberPadViewControllable>, NumberPadRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: NumberPadInteractable, viewController: NumberPadViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
