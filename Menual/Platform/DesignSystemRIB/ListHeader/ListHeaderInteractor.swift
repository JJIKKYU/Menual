//
//  ListHeaderInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import RIBs
import RxSwift

protocol ListHeaderRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ListHeaderPresentable: Presentable {
    var listener: ListHeaderPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol ListHeaderListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func listHeaderPressedBackBtn(isOnlyDetach: Bool)
}

final class ListHeaderInteractor: PresentableInteractor<ListHeaderPresentable>, ListHeaderInteractable, ListHeaderPresentableListener {

    weak var router: ListHeaderRouting?
    weak var listener: ListHeaderListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: ListHeaderPresentable) {
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
        listener?.listHeaderPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
