//
//  DividerInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift

protocol DividerRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DividerPresentable: Presentable {
    var listener: DividerPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DividerListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func dividerPressedBackBtn(isOnlyDetach: Bool)
}

final class DividerInteractor: PresentableInteractor<DividerPresentable>, DividerInteractable, DividerPresentableListener {

    weak var router: DividerRouting?
    weak var listener: DividerListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DividerPresentable) {
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
        listener?.dividerPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
