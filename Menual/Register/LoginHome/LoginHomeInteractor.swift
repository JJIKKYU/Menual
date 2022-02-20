//
//  LoginHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift

protocol LoginHomeRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachRegister()
}

protocol LoginHomePresentable: Presentable {
    var listener: LoginHomePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol LoginHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class LoginHomeInteractor: PresentableInteractor<LoginHomePresentable>, LoginHomeInteractable, LoginHomePresentableListener {
    
    weak var router: LoginHomeRouting?
    weak var listener: LoginHomeListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: LoginHomePresentable) {
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
    
    func pressedRegisterBtn() {
        router?.attachRegister()
    }
}
