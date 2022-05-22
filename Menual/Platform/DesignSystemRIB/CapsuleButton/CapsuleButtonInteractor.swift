//
//  CapsuleButtonInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift

protocol CapsuleButtonRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol CapsuleButtonPresentable: Presentable {
    var listener: CapsuleButtonPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol CapsuleButtonListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func capsuleButtonPressedBackBtn(isOnlyDetach: Bool)
}

final class CapsuleButtonInteractor: PresentableInteractor<CapsuleButtonPresentable>, CapsuleButtonInteractable, CapsuleButtonPresentableListener {

    weak var router: CapsuleButtonRouting?
    weak var listener: CapsuleButtonListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: CapsuleButtonPresentable) {
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
        listener?.capsuleButtonPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
