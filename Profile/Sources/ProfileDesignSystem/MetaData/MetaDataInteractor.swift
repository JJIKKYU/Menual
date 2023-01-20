//
//  MetaDataInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import RIBs
import RxSwift

protocol MetaDataRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol MetaDataPresentable: Presentable {
    var listener: MetaDataPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol MetaDataListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func metaDataPressedBackBtn(isOnlyDetach: Bool)
}

final class MetaDataInteractor: PresentableInteractor<MetaDataPresentable>, MetaDataInteractable, MetaDataPresentableListener {

    weak var router: MetaDataRouting?
    weak var listener: MetaDataListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: MetaDataPresentable) {
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
        listener?.metaDataPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
