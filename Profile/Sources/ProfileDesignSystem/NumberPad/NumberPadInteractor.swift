//
//  NumberPadInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs
import RxSwift

protocol NumberPadRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NumberPadPresentable: Presentable {
    var listener: NumberPadPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol NumberPadListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func numberPadPressedBackBtn(isOnlyDetach: Bool)
}

final class NumberPadInteractor: PresentableInteractor<NumberPadPresentable>, NumberPadInteractable, NumberPadPresentableListener {
    
    weak var router: NumberPadRouting?
    weak var listener: NumberPadListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: NumberPadPresentable) {
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
        listener?.numberPadPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
