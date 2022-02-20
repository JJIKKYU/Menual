//
//  RegisterHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift

protocol RegisterHomeRouting: Routing {
    func cleanupViews()
    func attachRegisterID()
    func attachRegisterPW()
    func registerDidClose()
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RegisterHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    // func registerHomeDidClose()
}

final class RegisterHomeInteractor: Interactor, RegisterHomeInteractable, AdaptivePresentationControllerDelegate {
    
    let presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    weak var router: RegisterHomeRouting?
    weak var listener: RegisterHomeListener?
    
    private let dependency: RegisterHomeDependency

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        dependency: RegisterHomeDependency
    ) {
        self.dependency = dependency
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        super.init()
        self.presentationDelegateProxy.delegate = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("registerHome didBecomActive")
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
        // TODO: Pause any business logic.
    }
    
    func pressedNextBtn() {
        print("RegisterHome :: pressedNextBtn from registerID")
        router?.attachRegisterPW()
    }
    
    func pressedNextBtnPW() {
        print("RegisterHome :: pressedNextBtn from registerPW")
    }
    
    func presentationControllerDidDismiss() {
        print("!!")
        router?.cleanupViews()
        // listener?.registerHomeDidClose()
    }
}
