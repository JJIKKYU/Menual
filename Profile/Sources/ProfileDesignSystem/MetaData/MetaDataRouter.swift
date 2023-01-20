//
//  MetaDataRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import RIBs

protocol MetaDataInteractable: Interactable {
    var router: MetaDataRouting? { get set }
    var listener: MetaDataListener? { get set }
}

protocol MetaDataViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MetaDataRouter: ViewableRouter<MetaDataInteractable, MetaDataViewControllable>, MetaDataRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: MetaDataInteractable, viewController: MetaDataViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
