//
//  MomentsInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift

protocol MomentsRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol MomentsPresentable: Presentable {
    var listener: MomentsPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol MomentsListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func momentsPressedBackBtn(isOnlyDetach: Bool)
}

final class MomentsInteractor: PresentableInteractor<MomentsPresentable>, MomentsInteractable, MomentsPresentableListener {

    weak var router: MomentsRouting?
    weak var listener: MomentsListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: MomentsPresentable) {
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
        listener?.momentsPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
