//
//  RegisterIDInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift

protocol RegisterIDRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RegisterIDPresentable: Presentable {
    var listener: RegisterIDPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol RegisterIDListener: AnyObject {
    func pressedNextBtn()
}

final class RegisterIDInteractor: PresentableInteractor<RegisterIDPresentable>, RegisterIDInteractable, RegisterIDPresentableListener {

    weak var router: RegisterIDRouting?
    weak var listener: RegisterIDListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(
        presenter: RegisterIDPresentable
    ) {
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
    
    func pressedNextBtn() {
        listener?.pressedNextBtn()
        print("registerID :: pressedNextBtn!")
    }
}
