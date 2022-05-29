//
//  TabsInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs
import RxSwift

protocol TabsRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TabsPresentable: Presentable {
    var listener: TabsPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol TabsListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func tabsPressedBackBtn(isOnlyDetach: Bool)
}

final class TabsInteractor: PresentableInteractor<TabsPresentable>, TabsInteractable, TabsPresentableListener {

    weak var router: TabsRouting?
    weak var listener: TabsListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: TabsPresentable) {
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
        listener?.tabsPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
