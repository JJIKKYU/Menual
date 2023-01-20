//
//  FABInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import RIBs
import RxSwift

protocol FABRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol FABPresentable: Presentable {
    var listener: FABPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol FABListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func FABPressedBackBtn(isOnlyDetach: Bool)
}

final class FABInteractor: PresentableInteractor<FABPresentable>, FABInteractable, FABPresentableListener {

    weak var router: FABRouting?
    weak var listener: FABListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: FABPresentable) {
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
        listener?.FABPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
