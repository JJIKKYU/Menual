//
//  GNBHeaderInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift

protocol GNBHeaderRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol GNBHeaderPresentable: Presentable {
    var listener: GNBHeaderPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol GNBHeaderListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func gnbHeaderPressedBackBtn(isOnlyDetach: Bool)
}

final class GNBHeaderInteractor: PresentableInteractor<GNBHeaderPresentable>, GNBHeaderInteractable, GNBHeaderPresentableListener {

    weak var router: GNBHeaderRouting?
    weak var listener: GNBHeaderListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: GNBHeaderPresentable) {
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
        listener?.gnbHeaderPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
