//
//  DesignSystemInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift

protocol DesignSystemRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DesignSystemPresentable: Presentable {
    var listener: DesignSystemPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DesignSystemListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class DesignSystemInteractor: PresentableInteractor<DesignSystemPresentable>, DesignSystemInteractable, DesignSystemPresentableListener {

    weak var router: DesignSystemRouting?
    weak var listener: DesignSystemListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DesignSystemPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
