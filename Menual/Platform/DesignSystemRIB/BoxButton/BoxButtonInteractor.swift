//
//  BoxButtonInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift

protocol BoxButtonRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BoxButtonPresentable: Presentable {
    var listener: BoxButtonPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol BoxButtonListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func boxButtonPressedBackBtn()
}

final class BoxButtonInteractor: PresentableInteractor<BoxButtonPresentable>, BoxButtonInteractable, BoxButtonPresentableListener {

    weak var router: BoxButtonRouting?
    weak var listener: BoxButtonListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: BoxButtonPresentable) {
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
    
    func pressedBackBtn() {
        listener?.boxButtonPressedBackBtn()
    }
}
