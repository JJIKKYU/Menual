//
//  PaginationInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import RIBs
import RxSwift

protocol PaginationRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PaginationPresentable: Presentable {
    var listener: PaginationPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol PaginationListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func paginationPressedBackBtn(isOnlyDetach: Bool)
}

final class PaginationInteractor: PresentableInteractor<PaginationPresentable>, PaginationInteractable, PaginationPresentableListener {

    weak var router: PaginationRouting?
    weak var listener: PaginationListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: PaginationPresentable) {
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
        listener?.paginationPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
