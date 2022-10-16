//
//  EmptyViewInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import RIBs
import RxSwift

protocol EmptyViewRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol EmptyViewPresentable: Presentable {
    var listener: EmptyViewPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol EmptyViewListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    
    func emptyPressedBackBtn(isOnlyDetach: Bool)
}

final class EmptyViewInteractor: PresentableInteractor<EmptyViewPresentable>, EmptyViewInteractable, EmptyViewPresentableListener {

    weak var router: EmptyViewRouting?
    weak var listener: EmptyViewListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: EmptyViewPresentable) {
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
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.emptyPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
